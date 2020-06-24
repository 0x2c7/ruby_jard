# frozen_string_literal: true
require 'forwardable'

module RubyJard
  class Session
    attr_reader :screen_manager, :backtrace, :frame

    def initialize(options = {})
      @options = options

      @backtrace = []
      @frame = nil

      @started = false
      @screen_manager = RubyJard::ScreenManager.new(session: self)
      @server = RubyJard::Server.new(options)
    end

    def start
      return if started?

      setup_pry
      setup_byebug

      @server.start
      @screen_manager.start

      @started = true
    end

    def started?
      @started == true
    end

    def attach
      start unless started?

      Byebug.attach
      Byebug.current_context.step_out(2, false)
    end

    def refresh
      @backtrace = Byebug.current_context.backtrace
      @frame = Byebug.current_context.frame
      @screen_manager.refresh
    end

    private

    def setup_pry
      Pry::Prompt.add(
        :jard,
        'Custom promt for Pry'
      ) do |context, _nesting, pry_instance, sep|
        format(
          '%<name>s >> ',
          in_count: pry_instance.input_ring.count,
          name: :jard,
          separator: sep
        )
      end
      Pry.config.prompt = Pry::Prompt[:jard]
      Pry.config.hooks = Pry::Hooks.new
    end

    def setup_byebug
      Byebug::Setting[:autolist] = false
      Byebug::Setting[:autoirb] = false
      Byebug::Setting[:autopry] = false
      Byebug::Context.processor = RubyJard::ReplProcessor
    end
  end
end
