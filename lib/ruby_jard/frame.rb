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
      @context.frame_file(located_pos)
    end

    def frame_line
      @context.frame_line(located_pos)
    end

    def frame_location
      location_at(@real_pos)
    end

    # Location to display for this frame. A native frame has no source file of
    # its own, so it points at the caller that invoked it.
    def display_location
      location_at(located_pos)
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
      native_at?(@real_pos)
    end

    def thread
      @context.thread
    end

    private

    def location_at(pos)
      frame_backtrace = @context.backtrace[pos]
      return nil if frame_backtrace.nil?

      frame_backtrace.first
    end

    # C methods, and core methods written in Ruby that report an
    # "<internal:...>" path (e.g. Integer#times since Ruby 3.3). Neither has
    # source code Jard can show.
    def native_at?(pos)
      @context.frame_binding(pos).nil? ||
        RubyJard::PathClassifier::INTERNAL_PATTERN.match?(@context.frame_file(pos).to_s)
    end

    # Ruby 3.4+ gives C frames no location, and internal frames point into
    # Ruby's own source. Attribute a native frame to its nearest non-native
    # caller, as Ruby's own caller_locations does and older Rubies did.
    def located_pos
      @located_pos ||=
        begin
          pos = @real_pos
          last_pos = @context.backtrace.length - 1
          pos += 1 while pos < last_pos && native_at?(pos)
          native_at?(pos) ? @real_pos : pos
        end
    end
  end
end
