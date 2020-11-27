# frozen_string_literal: true

module RubyJard
  # Proxy for Pry::REPL. Implement support for ::Readline only
  class PryReplProxy < Pry::REPL
    def read_line(current_prompt)
      handle_read_errors do
        Pry::InputLock.for(:all).interruptible_region do
          input.readline(current_prompt, false)
        end
      end
    end
  end

  # Proxy for Pry instance. Safely overidding some attributes
  class PryProxy < ::Pry
    # Some gems want to replace original Readline
    OriginalReadline = ::Readline
    # Some commands overlaps with Jard, Ruby, and even cause confusion for
    # users. It's better ignore or re-implement those commands.
    PRY_EXCLUDED_COMMANDS = [
      'pry-backtrace', # Redundant method for normal user
      'watch',         # Conflict with byebug and jard watch
      'edit',          # Sorry, but a file should not be editted while debugging, as it made breakpoints shifted
      'play',          # What if the played files or methods include jard again?
      'stat',          # Included in jard UI
      'backtrace',     # Re-implemented later
      'break',         # Re-implemented later
      'exit-all',      # Conflicted with continue
      'exit-program',  # We already have `exit` native command
      '!pry',          # No need to complicate things
      'jump-to',       # No need to complicate things
      'nesting',       # No need to complicate things
      'switch-to',     # No need to complicate things
      'disable-pry'    # No need to complicate things
    ].freeze

    Commands = Pry::CommandSet.new

    attr_reader :console

    def initialize(options = {})
      @redirected_input = options[:redirected_input]
      @redirected_output = options[:redirected_output]
      @original_input = options[:original_input]
      @original_output = options[:original_output]
      @state_hooks = options[:state_hooks] || {}
      options = options.merge(
        input: OriginalReadline,
        output: @redirected_output,
        prompt: pry_jard_prompt,
        commands: pry_command_set,
        quiet: true,
        hooks: pry_hooks
      )
      super(options)
    end

    def handle_line(line, *args)
      index = line.to_s.rindex(RubyJard::ReplManager::COMMAND_ESCAPE_SEQUENCE)
      if !index.nil?
        command = line[(index + RubyJard::ReplManager::COMMAND_ESCAPE_SEQUENCE.length)..-1]
        super(command, *args)
      else
        super(line, *args)
      end
    ensure
      exec_hook :after_handle_line, *args, self
    end

    def repl(target = nil)
      OriginalReadline.input = @redirected_input
      OriginalReadline.output = @redirected_output
      PryReplProxy.new(self, target: target).start
    ensure
      Readline.input = @original_input
      Readline.output = @original_output
    end

    def pager
      RubyJard::Pager.new(self)
    end

    private

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

    def pry_command_set
      set = Pry::CommandSet.new
      set.import_from(
        Pry::Commands,
        *(Pry::Commands.list_commands - PRY_EXCLUDED_COMMANDS)
      )
      set.import_from(
        PryProxy::Commands,
        *PryProxy::Commands.list_commands
      )
      set
    end

    def pry_hooks
      hooks = Pry::Hooks.default
      hooks.add_hook(:after_read, :jard_proxy_acquire_lock) do |_read_string, _pry|
        @state_hooks[:after_read]&.call
      end
      hooks.add_hook(:after_handle_line, :jard_proxy_release_lock) do
        @state_hooks[:after_handle_line]&.call
      end
      hooks.add_hook(:before_pager, :jard_proxy_before_pager) do
        @state_hooks[:before_pager]&.call
      end
      hooks.add_hook(:after_pager, :jard_proxy_after_pager) do
        @state_hooks[:after_pager]&.call
      end
    end
  end
end

RubyJard::PryProxy.init

require 'ruby_jard/commands/base_command'
require 'ruby_jard/commands/validation_helpers'
require 'ruby_jard/commands/color_helpers'
require 'ruby_jard/commands/continue_command'
require 'ruby_jard/commands/exit_command'
require 'ruby_jard/commands/up_command'
require 'ruby_jard/commands/down_command'
require 'ruby_jard/commands/next_command'
require 'ruby_jard/commands/step_command'
require 'ruby_jard/commands/step_out_command'
require 'ruby_jard/commands/frame_command'
require 'ruby_jard/commands/list_command'
require 'ruby_jard/commands/skip_command'
require 'ruby_jard/commands/jard_command'
require 'ruby_jard/commands/help_command'
