# frozen_string_literal: true

module RubyJard
  ##
  # Byebug allows customizing processor with a series of hooks (https://github.com/deivid-rodriguez/byebug/blob/e1fb8209d56922f7bafd128af84e61568b6cd6a7/lib/byebug/processors/command_processor.rb)
  #
  # This class is a bridge between REPL library and Byebug. It is inherited from
  # Byebug::CommandProcessor, the processor is triggered. It starts draw the
  # UI, starts a new REPL session, listen for control-flow events threw from
  # repl, and triggers Byebug debugger if needed.
  #
  class ReplProcessor < Byebug::CommandProcessor
    def initialize(context, interface = LocalInterface.new)
      super(context, interface)
      @repl_proxy = RubyJard::ReplProxy.new(
        key_bindings: RubyJard.global_key_bindings
      )
    end

    def at_line
      process_commands_with_lock
    end

    def at_return(_)
      process_commands_with_lock
    end

    def at_end
      process_commands_with_lock
    end

    private

    def process_commands_with_lock
      allowing_other_threads do
        RubyJard.current_session.lock do
          process_commands
        end
      end
    end

    def process_commands(update = true)
      if update
        RubyJard.current_session.update
        RubyJard::ScreenManager.update
      end
      return_value = nil

      flow = RubyJard::ControlFlow.listen do
        return_value = @repl_proxy.repl(frame._binding)
      end

      unless flow.nil?
        command = flow.command
        send("handle_#{command}_command", flow.arguments)
      end

      return_value
    rescue StandardError => e
      RubyJard::ScreenManager.draw_error(e)
      raise
    end

    def handle_next_command(options = {})
      times = options[:times] || 1
      Byebug.current_context.step_over(times, Byebug.current_context.frame.pos)
      proceed!
    end

    def handle_step_command(_options = {})
      Byebug.current_context.step_into(1, Byebug.current_context.frame.pos)
      proceed!
    end

    def handle_step_out_command(_options = {})
      # TODO: handle c-frame and out of range frames
      Byebug.current_context.frame = 1
      proceed!
      Byebug.current_context.step_over(1, Byebug.current_context.frame.pos)
      proceed!
    end

    def handle_up_command(_options = {})
      next_frame = [
        Byebug.current_context.frame.pos + 1,
        Byebug.current_context.backtrace.length - 1
      ].min
      while Byebug::Frame.new(Byebug.current_context, next_frame).c_frame? &&
            next_frame < Byebug.current_context.backtrace.length - 1
        next_frame += 1
      end
      Byebug.current_context.frame = next_frame
      proceed!
      process_commands
    end

    def handle_down_command(options = {})
      times = options[:times] || 1
      next_frame = Byebug.current_context.frame.pos
      times.times do
        next_frame = [next_frame - 1, 0].max
        while Byebug::Frame.new(Byebug.current_context, next_frame).c_frame? &&
              next_frame > 0
          next_frame -= 1
        end
      end
      Byebug.current_context.frame = next_frame
      proceed!
      process_commands
    end

    def handle_frame_command(options)
      next_frame = options[:frame].to_i
      if Byebug::Frame.new(Byebug.current_context, next_frame).c_frame?
        puts "Error: Frame #{next_frame} is a c-frame. Not able to inspect c layer!"
        process_commands(false)
      else
        Byebug.current_context.frame = next_frame
        proceed!
        process_commands(true)
      end
    end

    def handle_continue_command(_options = {})
      # Do nothing
    end

    def handle_key_binding_command(options = {})
      method_name = "handle_#{options[:action]}_command"
      if respond_to?(method_name, true)
        send(method_name)
      else
        raise RubyJard::Error,
              "Fail to handle key binding `#{options[:action]}`"
      end
    end

    def handle_list_command(_options = {})
      process_commands
    end

    def handle_color_scheme_command(options = {})
      RubyJard.config.color_scheme = options[:color_scheme]
      process_commands
    end
  end
end
