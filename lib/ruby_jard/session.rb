# frozen_string_literal: true

module RubyJard
  ##
  # Centralized flow control and data storage to feed into screens. Each
  # process supposes to have only one instance of this class.
  # TODO: If attachment event happens after any threads are created, race
  # condition may happen. Should use a mutex to wrap around.
  # TODO: This class is created to store data, but byebug data structures are
  # leaked, and accessible from outside and this doesn't work if screens stay in
  # other processes. Therefore, an internal, jard-specific data mapping should
  # be built.
  class Session
    attr_reader :contexts, :current_context

    def initialize(options = {})
      @options = options

      @current_context = options[:current_context] || []
      @contexts = options[:contexts] || []

      @started = false
      @session_lock = Mutex.new
    end

    def start
      return if started?

      ##
      # Globally configure Byebug. Byebug doesn't allow configuration by instance.
      # So, I have no choice.
      # TODO: Byebug autoloaded configuration may override those values.
      Byebug::Setting[:autolist] = false
      Byebug::Setting[:autoirb] = false
      Byebug::Setting[:autopry] = false
      Byebug::Context.processor = RubyJard::ReplProcessor
      # Exclude all files in Ruby Jard source code from the stacktrace.
      Byebug::Context.ignored_files = Byebug::Context.all_files + Dir.glob(
        File.join(
          File.expand_path(__dir__, '../lib'),
          '**',
          '*.rb'
        )
      )
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

    def update
      @current_context = Byebug.current_context
      @contexts = Byebug.contexts
    end

    def frame
      @current_context.frame
    end

    def backtrace
      @current_context.backtrace
    end

    def frame_file
      frame.file
    end

    def frame_line
      frame.line
    end

    def frame_location
      frame_backtrace = backtrace[frame.pos]
      return nil if frame_backtrace.nil?

      frame_backtrace.first
    end

    def frame_self
      frame._self
    end

    def frame_class
      frame._class
    end

    def frame_binding
      frame._binding
    end

    def frame_method
      frame._method
    end

    def lock
      raise RubyJard::Error, 'This method requires a block' unless block_given?

      # TODO: This doesn't solve anything. However, debugging a multi-threaded process is hard.
      # Let's deal with that later.
      @session_lock.synchronize do
        yield
      end
    end
  end
end
