# frozen_string_literal: true

module RubyJard
  ##
  # A wrapper for thread object to prevent direc access to thread data
  class ThreadInfo
    class << self
      def labels
        @labels ||= {}
      end

      def clear_labels
        @labels = {}
        @next_label = 0
      end

      def next_label
        @next_label ||= 0
        @next_label += 1
      end

      def generate_label_for(id)
        return '' if id.nil?
        return labels[id] if labels[id]

        labels[id] = next_label.to_s
      end
    end

    attr_reader :id, :label

    def initialize(thread)
      raise RubyJard::Error, 'Expected Thread object or nil' if !thread.is_a?(::Thread) && !thread.nil?

      @thread = thread
      @id = thread&.object_id
      @label = self.class.generate_label_for(@id)
    end

    def name
      @thread&.name
    end

    def status
      s = @thread&.status
      s == false ? 'exited' : s
    end

    def alive?
      @thread&.alive? || false
    end

    def backtrace_locations
      @thread&.backtrace_locations || []
    end

    # rubocop:disable Style/CaseLikeIf
    def ==(other)
      if other.is_a?(::Thread)
        @thread == other
      elsif other.is_a?(ThreadInfo)
        @id == other.id
      else
        raise RubyJard::Error, 'Invalid comparation'
      end
    end
    # rubocop:enable Style/CaseLikeIf
  end
end
