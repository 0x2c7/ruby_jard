# frozen_string_literal: true

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
require 'ruby_jard/commands/jard_command'

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
    def initialize(context, *args)
      super(context, *args)
      @config = RubyJard.config
      @repl_proxy = RubyJard::ReplProxy.new(
        key_bindings: RubyJard.global_key_bindings
      )
      @previous_flow = nil
    end

    def at_line
      process_commands_with_lock
    end

    def at_return(_return_value)
      process_commands_with_lock
    end

    def at_end
      process_commands_with_lock
    end

    private

    def process_commands_with_lock
      allowing_other_threads do
        RubyJard::Session.lock do
          RubyJard::Session.sync
          unless RubyJard::Session.should_stop?
            handle_flow(@previous_flow)
            return
          end

          process_commands
        end
      end
    end

    def process_commands(redraw = true)
      RubyJard::Session.sync
      RubyJard::ScreenManager.draw_screens if redraw

      return_value = nil

      flow = RubyJard::ControlFlow.listen do
        return_value = @repl_proxy.repl(frame._binding)
      end

      handle_flow(flow)

      return_value
    rescue StandardError => e
      RubyJard::ScreenManager.draw_error(e)
      raise
    end

    def handle_flow(flow)
      return if flow.nil?

      @previous_flow = flow
      command = flow.command
      send("handle_#{command}_command", flow.arguments)
    end

    def handle_next_command(options = {})
      times = options[:times] || 1
      RubyJard::Session.step_over(times)
      proceed!
    end

    def handle_step_command(options = {})
      times = options[:times] || 1
      RubyJard::Session.step_into(times)
      proceed!
    end

    def handle_step_out_command(options = {})
      times = options[:times] || 1

      next_frame = up_n_frames(RubyJard::Session.current_frame.pos, times)
      RubyJard::Session.frame = next_frame
      RubyJard::Session.step_over(1)
      proceed!
    end

    def handle_up_command(options = {})
      times = options[:times] || 1

      next_frame = up_n_frames(RubyJard::Session.current_frame.pos, times)
      RubyJard::Session.frame = next_frame
      proceed!
      process_commands
    end

    def handle_down_command(options = {})
      times = options[:times] || 1
      next_frame = down_n_frames(RubyJard::Session.current_frame.pos, times)
      RubyJard::Session.frame = next_frame
      proceed!
      process_commands
    end

    def handle_frame_command(options)
      next_frame = options[:frame].to_i
      if RubyJard::Session.current_backtrace[next_frame].c_frame?
        RubyJard::ScreenManager.puts "Error: Frame #{next_frame} is a c-frame. Not able to inspect c layer!"
        process_commands(false)
      else
        RubyJard::Session.frame = next_frame
        proceed!
        process_commands(true)
      end
    end

    def handle_continue_command(_options = {})
      RubyJard::ScreenManager.puts '▸▸ Program resumed ▸▸'
    end

    def handle_exit_command(_options = {})
      Kernel.exit
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

    def handle_switch_filter_command(_options = {})
      index = RubyJard::PathFilter::FILTERS.index(@config.filter) || -1
      index = (index + 1) % RubyJard::PathFilter::FILTERS.length
      @config.filter = RubyJard::PathFilter::FILTERS[index]

      process_commands
    end

    def up_n_frames(current_frame, times)
      next_frame = current_frame
      times.times do
        next_frame = [next_frame + 1, RubyJard::Session.current_backtrace.length - 1].min
        while RubyJard::Session.current_backtrace[next_frame].c_frame? &&
              next_frame < RubyJard::Session.current_backtrace.length - 1
          next_frame += 1
        end
      end
      next_frame
    end

    def down_n_frames(current_frame, times)
      next_frame = current_frame
      times.times do
        next_frame = [next_frame - 1, 0].max
        while RubyJard::Session.current_backtrace[next_frame].c_frame? &&
              next_frame > 0
          next_frame -= 1
        end
      end
      next_frame
    end
  end
end
