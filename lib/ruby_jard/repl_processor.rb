# frozen_string_literal: true

module RubyJard
  class ReplProcessor < Byebug::CommandProcessor
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
          if @pry.nil?
            @pry = Pry.start(frame._binding)
          else
            @pry.repl(frame._binding)
          end
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
      context.step_out(1)
    end

    def handle_continue_command(_pry_instance, _options)
      # Do nothing
    end
  end
end
