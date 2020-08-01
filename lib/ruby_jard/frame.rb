# frozen_string_literal: true

module RubyJard
  ##
  # This class is a wrapper for Byebug::Frame. This class prevents direct
  # access to Byebug's internal data structure, provides some more helpers
  # and make Jard easier to test.
  class Frame
    attr_reader :pos

    def initialize(context, pos)
      @context = context
      @pos = pos
    end

    def frame_file
      @context.frame_file(@pos)
    end

    def frame_line
      @context.frame_line(@pos)
    end

    def frame_location
      frame_backtrace = @context.backtrace[@pos]
      return nil if frame_backtrace.nil?

      frame_backtrace.first
    end

    def frame_self
      @context.frame_self(@pos)
    end

    def frame_class
      @context.frame_class(@pos)
    end

    def frame_binding
      @context.frame_binding(@pos)
    end

    def frame_method
      @context.frame_method(@pos)
    end

    def c_frame?
      frame_binding.nil?
    end

    def thread
      @context.thread
    end
  end
end
