# frozen_string_literal: true

module RubyJard
  ##
  # This class is a wrapper for Byebug::Frame. This class prevents direct
  # access to Byebug's internal data structure, provides some more helpers
  # and make Jard easier to test.
  class Frame
    attr_reader :real_pos
    attr_writer :visible
    attr_accessor :virtual_pos

    def initialize(context, real_pos, virtual_pos: nil)
      @context = context
      @real_pos = real_pos
      @virtual_pos = virtual_pos

      @visible = true
    end

    def visible?
      @visible == true
    end

    def hidden?
      @visible == false
    end

    def frame_file
      @context.frame_file(@real_pos)
    end

    def frame_line
      @context.frame_line(@real_pos)
    end

    def frame_location
      frame_backtrace = @context.backtrace[@real_pos]
      return nil if frame_backtrace.nil?

      frame_backtrace.first
    end

    def frame_self
      @context.frame_self(@real_pos)
    end

    def frame_class
      @context.frame_class(@real_pos)
    end

    def frame_binding
      @context.frame_binding(@real_pos)
    end

    def frame_method
      @context.frame_method(@real_pos)
    end

    def c_frame?
      frame_binding.nil?
    end

    def thread
      @context.thread
    end
  end
end
