# frozen_string_literal: true
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
  end
end
