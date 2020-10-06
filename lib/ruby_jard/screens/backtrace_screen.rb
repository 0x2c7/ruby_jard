# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Backtrace screen implements the content to display current thread's backtrace to the user.
    class BacktraceScreen < RubyJard::Screen
      include ::RubyJard::Span::DSL

      def initialize(*args)
        super(*args)
        @current_frame = @session.current_frame
        @frames =
          @session
          .current_backtrace
          .select(&:visible?)
          .sort { |a, b| a.virtual_pos.to_i <=> b.virtual_pos.to_i }
        insert_current_frame
        @selected =
          if @current_frame.nil?
            0
          else
            @frames.find_index { |f| f.real_pos == @current_frame.real_pos }
          end
        @frames_count = @frames.length
        @hidden_frames_count = @session.current_backtrace.length - @frames.length

        @path_decorator = RubyJard::Decorators::PathDecorator.new
        @reflection = RubyJard::Reflection.instance
      end

      def title
        if @hidden_frames_count <= 0
          ['Backtrace', "#{@frames_count} frames"]
        else
          ['Backtrace', "#{@frames_count} frames - #{@hidden_frames_count} hidden"]
        end
      end

      def build
        @rows = @frames.map do |frame|
          Row.new(
            Column.new(span_frame_pos(frame)),
            Column.new(
              span_class_label(frame),
              span_label_preposition,
              span_method_label(frame),
              span_path(frame)
            ),
            line_limit: 2
          )
        end
      end

      private

      def span_frame_pos(frame)
        frame_pos_label =
          if frame.hidden?
            '*'.rjust(@frames_count.to_s.length)
          else
            frame.virtual_pos.to_s.rjust(@frames_count.to_s.length)
          end
        if frame.real_pos == @current_frame.real_pos
          text_selected("⮕ #{frame_pos_label}")
        else
          text_dim("  #{frame_pos_label}")
        end
      end

      def span_class_label(frame)
        self_class = @reflection.call_class(frame.frame_self)
        class_label =
          if frame.frame_class.nil? || self_class == frame.frame_class
            if @reflection.call_is_a?(frame.frame_self, Class)
              frame.frame_self.name
            else
              self_class.name
            end
          elsif frame.frame_class.singleton_class?
            # No easy way to get the original class of a singleton class
            frame.frame_self.respond_to?(:name) ? frame.frame_self.name : frame.frame_self.to_s
          else
            frame.frame_class.name
          end

        c_frame = frame.c_frame? ? '[c] ' : ''
        text_constant("#{c_frame}#{class_label} ")
      end

      def span_label_preposition
        text_primary('in ')
      end

      def span_method_label(frame)
        method_label =
          if frame.frame_location.label != frame.frame_location.base_label
            "#{frame.frame_location.base_label} (#{frame.frame_location.label.split(' ').first})"
          else
            frame.frame_location.base_label
          end
        text_method("#{method_label} ")
      end

      def span_path(frame)
        path_label, = @path_decorator.decorate(
          frame.frame_location.path, frame.frame_location.lineno
        )
        text_primary(path_label)
      end

      def insert_current_frame
        return if @current_frame.visible?

        index = @frames.find_index { |f| @current_frame.real_pos < f.real_pos }
        if index.nil?
          @frames << @current_frame
        else
          @frames.insert(index, @current_frame)
        end
      end
    end
  end
end

RubyJard::Screens.add_screen('backtrace', RubyJard::Screens::BacktraceScreen)
