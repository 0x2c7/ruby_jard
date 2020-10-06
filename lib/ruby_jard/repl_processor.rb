# frozen_string_literal: true

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
    # NOTE: This is an experimental feature. If the flow is repeated too much,
    # the debugger refuses to continue, and step out instead.
    # Why?
    # Filtering feature is a killing feature of Jard, but it is not affective,
    # especially with step command. Other commands, such as next, run fast
    # enough to get up to the frame it should stop. However, step leads the whole
    # program down to the rabbit hole. The situation gets worse if a method call
    # triggers Ruby autoload, leads to millions of repeated flows until the program
    # gets out. In a simple benchmark, it takes minutes to finish. Therefore, as
    # soon Jard repeats up to a threashold, it should give up, and step out to let
    # the program continues. The correctness of the debugger is not affected, while
    # this approach brings better experience. In worst cases, I can recommend the users
    # to put a breakpoint manually instead.
    REPEATED_FLOW_TIME_THRESHOLD = 5 # 5 seconds
    REPEATED_FLOW_COUNT_THRESHOLD = 20_000

    def initialize(context, *args)
      super(context, *args)
      @config = RubyJard.config

      @session = RubyJard::Session.instance
      @screen_manager = @session.screen_manager
      @repl_proxy = @session.repl_proxy

      @repeated_flow = 0
      @last_repeat_at = nil
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
        @session.lock do
          @session.sync(@context)
          unless @session.should_stop?(@context.frame.file)
            @last_repeat_at ||= Time.now.to_f
            @repeated_flow += 1

            if @repeated_flow > REPEATED_FLOW_COUNT_THRESHOLD &&
               Time.now.to_f - @last_repeat_at > REPEATED_FLOW_TIME_THRESHOLD
              @previous_flow = RubyJard::ControlFlow.new(:step_out)
            end
            @previous_flow ||= RubyJard::ControlFlow.new(:next)
            handle_flow(@previous_flow)
            return
          end

          @repeated_flow = 0
          @last_repeat_at = nil
          @previous_flow = nil
          process_commands
        end
      end
    end

    def process_commands(redraw = true)
      @session.sync(@context)
      RubyJard.benchmark(:redraw_screens) do
        @screen_manager.draw_screens if redraw
      end

      return_value = nil

      flow = RubyJard::ControlFlow.listen do
        return_value = @repl_proxy.repl(frame._binding)
      end

      RubyJard.benchmark(:handle_flow) do
        handle_flow(flow)
      end

      return_value
    rescue StandardError => e
      @screen_manager.draw_error(e)
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
      @session.step_over(times)
    end

    def handle_step_command(options = {})
      times = options[:times] || 1
      @session.step_into(times)
    end

    def handle_step_out_command(options = {})
      times = options[:times] || 1

      next_frame = up_n_frames(@session.current_frame.real_pos, times)
      @session.frame = next_frame
      @session.step_over(1)
    end

    def handle_up_command(options = {})
      times = options[:times] || 1

      next_frame = up_n_frames(@session.current_frame.real_pos, times)
      @session.frame = next_frame
      process_commands
    end

    def handle_down_command(options = {})
      times = options[:times] || 1
      next_frame = down_n_frames(@session.current_frame.real_pos, times)
      @session.frame = next_frame
      process_commands
    end

    def handle_frame_command(options)
      next_frame = find_frame(options[:frame].to_i)
      if next_frame.nil?
        # There must be an error in outer validators
        @screen_manager.console.puts 'Error: Frame not found. There should be an error with Jard.'
        process_commands(false)
      elsif next_frame.c_frame?
        @screen_manager.console.puts "Error: Frame #{next_frame} is a c-frame. Not able to inspect c layer!"
        process_commands(false)
      else
        @session.frame = next_frame.real_pos
        process_commands(true)
      end
    end

    def handle_continue_command(_options = {})
      @screen_manager.console.puts '▸▸ Program resumed ▸▸'
      @session.stop
    end

    def handle_skip_command(options)
      times = options[:times] || 1
      @session.skip(times)
    end

    def handle_exit_command(_options = {})
      @session.stop
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
      @config.filter = RubyJard::PathFilter.next_filter(@config.filter)

      process_commands
    end

    def up_n_frames(real_pos, times)
      next_frame = real_pos
      times.times do
        next_frame = [next_frame + 1, @session.current_backtrace.length - 1].min
        while next_frame < @session.current_backtrace.length &&
              (
                @session.current_backtrace[next_frame].c_frame? ||
                @session.current_backtrace[next_frame].hidden?
              )
          next_frame += 1
        end
        return real_pos if next_frame >= @session.current_backtrace.length
      end
      next_frame
    end

    def down_n_frames(real_pos, times)
      next_frame = real_pos
      times.times do
        next_frame = [next_frame - 1, 0].max
        while next_frame >= 0 &&
              (
                @session.current_backtrace[next_frame].c_frame? ||
                @session.current_backtrace[next_frame].hidden?
              )

          next_frame -= 1
        end
        return real_pos if next_frame < 0
      end
      next_frame
    end

    def find_frame(virtual_pos)
      @session.current_backtrace.find { |frame| frame.virtual_pos == virtual_pos }
    end
  end
end
