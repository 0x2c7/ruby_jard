# frozen_string_literal: true

module RubyJard
  ##
  # Byebug allows customizing processor with a series of hooks (https://github.com/deivid-rodriguez/byebug/blob/e1fb8209d56922f7bafd128af84e61568b6cd6a7/lib/byebug/processors/command_processor.rb)
  #
  # This class is a bridge between Pry and Byebug. It is inherited from
  # Byebug::CommandProcessor, the processor is triggered. It starts draw the
  # UI, starts a new pry session, listen for control-flow events threw from
  # pry commands (lib/commands/*), and triggers Byebug debugger if needed.
  #
  class ReplProcessor < Byebug::CommandProcessor
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

    def initialize(context, interface = LocalInterface.new)
      super(context, interface)
    end

    def at_line
      process_commands
    end

    def at_return(_)
      process_commands
    end

    def at_end
      process_commands
    end

    private

    def process_commands
      RubyJard.current_session.refresh
      return_value = nil

      flow = catch(:control_flow) do
        return_value = allowing_other_threads do
          start_pry_session
        end
        {}
      end

      @pry = flow[:pry]
      if @pry
        @pry.binding_stack.clear
        send("handle_#{flow[:command]}_command", @pry, flow[:options])
      end

      return_value
    end

    def start_pry_session
      if @pry.nil?
        @pry = Pry.start(
          frame._binding,
          prompt: pry_jard_prompt,
          quiet: true,
          commands: pry_command_set
        )
      else
        @pry.repl(frame._binding)
      end
    end

    def handle_next_command(_pry_instance, _options)
      Byebug::NextCommand.new(self, 'next').execute
    end

    def handle_step_command(_pry_instance, _options)
      Byebug::StepCommand.new(self, 'step').execute
    end

    def handle_up_command(_pry_instance, _options)
      Byebug::UpCommand.new(self, 'up 1').execute

      process_commands
    end

    def handle_down_command(_pry_instance, _options)
      Byebug::DownCommand.new(self, 'down 1').execute

      process_commands
    end

    def handle_finish_command(_pry_instance, _options)
      RubyJard.current_session.disable
      context.step_out(2, true)
      Byebug::NextCommand.new(self, 'next').execute
      RubyJard.current_session.enable
    end

    def handle_continue_command(_pry_instance, _options)
      # Do nothing
    end

    def pry_command_set
      @pry_command_set ||=
        begin
          set = Pry::CommandSet.new
          set.import_from(
            Pry.config.commands,
            *(Pry.config.commands.list_commands - PRY_EXCLUDED_COMMANDS)
          )
          set
        end
    end

    def pry_jard_prompt
      @pry_jard_prompt ||=
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
  end
end
