# frozen_string_literal: true

require 'ruby_jard/commands/continue_command'
require 'ruby_jard/commands/up_command'
require 'ruby_jard/commands/down_command'
require 'ruby_jard/commands/next_command'
require 'ruby_jard/commands/step_command'
require 'ruby_jard/commands/frame_command'

module RubyJard
  ##
  # A wrapper to wrap around Pry instance.
  #
  # Pry depends heavily on GNU Readline, or any Readline-like input libraries. Those libraries
  # serve limited use cases, and specific interface to support those. Unfortunately, to serve
  # Jard's keyboard functionalities, those libraries must support individual keyboard events,
  # programmatically input control, etc. Ruby's GNU Readline binding obviously doesn't support
  # those fancy features. Other pure-ruby implementation such as coolline, tty-reader is not
  # a perfit fit, while satisfying performance and boringly stablility of GNU Readline. Indeed,
  # while testing those libraries, I meet some weird quirks, lagging, cursor jumping around.
  # Putting efforts in a series of monkey patches help a little bit, but it harms in long-term.
  # Re-implementing is just like jumping into another rabbit hole.
  #
  # That's why I come up with another approach:
  # - Create a proxy wrapping around pry instance, so that it reads characters one by one, in
  # *raw* mode
  # - Keyboard combinations are captured and handled before piping the rest to the pry instance
  # - The proxy interacts with Pry's REPL loop via Pry hooks (Thank God) to seamlessly switch
  # between *raw* mode and *cooked* mode while Pry interacts with TTY.
  # - Control flow instructions are threw out, and captured by ReplProcessor.
  #
  # As a result, Jard may support key-binding customization without breaking pry functionalities.
  class ReplProxy
    # Some commands overlaps with Jard, Ruby, and even cause confusion for
    # users. It's better ignore or re-implement those commands.
    PRY_EXCLUDED_COMMANDS = [
      'pry-backtrace', # Redundant method for normal user
      'watch',         # Conflict with byebug and jard watch
      'whereami',      # Jard already provides similar. Keeping this command makes conflicted experience
      'edit',          # Sorry, but a file should not be editted while debugging, as it made breakpoints shifted
      'play',          # What if the played files or methods include jard again?
      'stat',          # Included in jard UI
      'backtrace',     # Re-implemented later
      'break',         # Re-implemented later
      'exit',          # Conflicted with continue
      'exit-all',      # Conflicted with continue
      'exit-program',  # We already have `exit` native command
      '!pry',          # No need to complicate things
      'jump-to',       # No need to complicate things
      'nesting',       # No need to complicate things
      'switch-to',     # No need to complicate things
      'disable-pry'    # No need to complicate things
    ].freeze

    COMMANDS = [
      CMD_FLOW      = :flow,
      CMD_EVALUATE  = :evaluate,
      CMD_IDLE      = :idle,
      CMD_INTERRUPT = :interrupt
    ].freeze

    DEFAULT_KEY_BINDINGS = [
      KEY_BINDING_ENDLINE   = :end_line,
      KEY_BINDING_INTERRUPT = :interrupt
    ].freeze

    KEYPRESS_POLLING = 0.1 # 100ms

    def initialize(key_bindings = nil)
      @pry_read_stream, @pry_write_stream = IO.pipe
      @pry = pry_instance
      @commands = Queue.new
      @key_bindings = key_bindings || RubyJard::KeyBindings.new
      push_internal_key_bindings
    end

    def read_key
      STDIN.getch(min: 0, time: KEYPRESS_POLLING)
    end

    def repl(current_binding)
      Readline.input = @pry_read_stream
      @commands.clear
      @pry.binding_stack.clear

      pry_thread = Thread.new do
        flow = RubyJard::ControlFlow.listen do
          @pry.repl(current_binding)
        end
        @commands << [CMD_FLOW, flow]
      end
      loop do
        break unless pry_thread.alive?

        if @commands.empty?
          listen_key_press
        else
          cmd, value = @commands.deq
          handle_command(pry_thread, cmd, value)
        end
      end
      pry_thread&.join
      Readline.input = STDIN
    end

    def listen_key_press
      key = @key_bindings.match { read_key }
      if key.is_a?(RubyJard::KeyBinding)
        handle_key_binding(key)
      elsif !key.empty?
        @pry_write_stream.write(key)
      end
    end

    def handle_key_binding(key_binding)
      case key_binding.action
      when KEY_BINDING_ENDLINE
        @pry_write_stream.write(key_binding.sequence)
        @commands << [CMD_EVALUATE]
      when KEY_BINDING_INTERRUPT
        @commands << [CMD_INTERRUPT]
      end
    end

    def handle_command(pry_thread, cmd, value)
      case cmd
      when CMD_FLOW
        RubyJard::ControlFlow.dispatch(value)
      when CMD_EVALUATE
        loop do
          cmd, value = @commands.deq
          break if [CMD_IDLE, CMD_FLOW, CMD_INTERRUPT].include?(cmd)
        end
        handle_command(pry_thread, cmd, value)
      when CMD_INTERRUPT
        handle_interrupt_command(pry_thread)
      when CMD_IDLE
        # Ignore
      when CMD_NEXT
        pry_thread.exit
        RubyJard::ControlFlow.dispatch(:next)
      end
    end

    def handle_interrupt_command(pry_thread)
      pry_thread.raise Interrupt if pry_thread.alive?
      loop do
        begin
          sleep 0.1
        rescue Interrupt
          # Interrupt spam. Ignore.
        end
        break unless pry_thread.pending_interrupt?
      end
    end

    def pry_instance
      pry_instance = Pry.new(
        prompt: pry_jard_prompt,
        quiet: true,
        commands: pry_command_set,
        hooks: pry_hooks
      )
      # I'll be burned in hell for this
      # TODO: Contact pry author to add :after_handle_line hook
      class << pry_instance
        def _jard_handle_line(*args)
          _original_handle_line(*args)
          exec_hook :after_handle_line, *args, self
        end
        alias_method :_original_handle_line, :handle_line
        alias_method :handle_line, :_jard_handle_line
      end
      pry_instance
    end

    def pry_command_set
      set = Pry::CommandSet.new
      set.import_from(
        Pry.config.commands,
        *(Pry.config.commands.list_commands - PRY_EXCLUDED_COMMANDS)
      )
      set
    end

    def pry_jard_prompt
      Pry::Prompt.new(
        :jard,
        'Custom pry promt for Jard', [
          proc do |_context, _nesting, _pry_instance|
            'jard >> '
          end,
          proc do |_context, _nesting, _pry_instance|
            'jard *> '
          end
        ]
      )
    end

    def pry_hooks
      hooks = Pry::Hooks.default
      hooks.add_hook(:after_read, :jard_proxy_acquire_lock) do |read_string, _pry|
        @commands <<
          if Pry::Code.complete_expression?(read_string)
            [CMD_EVALUATE]
          else
            [CMD_IDLE]
          end
      rescue SyntaxError
        @commands << [CMD_IDLE]
      end
      hooks.add_hook(:after_handle_line, :jard_proxy_release_lock) do
        @commands << [CMD_IDLE]
      end
    end

    def push_internal_key_bindings
      @key_bindings.push(["\n", "\r\n", "\r"], KEY_BINDING_ENDLINE)
      @key_bindings.push("\u0003", KEY_BINDING_INTERRUPT)
    end
  end
end
