# frozen_string_literal: true

module RubyJard
  # A class to store the state with multi-thread guarding
  # Ready => Processing/Exiting
  # Processing => Ready again
  # Exiting => Exited
  # Exited => Ready
  class ReplState
    STATES = [
      STATE_READY      = 0,
      STATE_EXITING    = 1,
      STATE_PROCESSING = 2,
      STATE_EXITED     = 3
    ].freeze

    def initialize
      @state = STATE_EXITED
      @mutex = Mutex.new
      @pager = false
    end

    def check(method_name)
      @mutex.synchronize { yield if send(method_name) }
    end

    def pager?
      @pager == true
    end

    def set_pager!
      @pager = true
    end

    def clear_pager!
      @pager = false
    end

    def ready?
      @state == STATE_READY
    end

    def ready!
      if ready? || processing? || exited?
        @mutex.synchronize { @state = STATE_READY }
      end
    end

    def processing?
      @state == STATE_PROCESSING
    end

    def processing!
      return unless ready?

      @mutex.synchronize { @state = STATE_PROCESSING }
    end

    def exiting?
      @state == STATE_EXITING
    end

    def exiting!
      @mutex.synchronize { @state = STATE_EXITING }
    end

    def exited?
      @state == STATE_EXITED
    end

    def exited!
      @mutex.synchronize { @state = STATE_EXITED }
    end
  end
end
