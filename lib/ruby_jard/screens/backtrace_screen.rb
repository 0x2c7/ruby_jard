# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Backtrace screen implements the content to display current thread's backtrace to the user.
    class BacktraceScreen < RubyJard::Screen
      def initialize(*args)
        super(*args)
        @frames = @session.current_backtrace.select(&:visible?)
        @selected =
          if @session.current_frame.nil?
            0
          elsif @session.current_frame.hidden?
            -1
          else
            @session.current_frame.virtual_pos
          end
        @frames_count = @frames.length
        @hidden_frames_count = @session.current_backtrace.count(&:hidden?)

        @path_decorator = RubyJard::Decorators::PathDecorator.new
      end

      def title
        if @hidden_frames_count == 0
          ['Backtrace', "#{@frames_count} frames"]
        else
          ['Backtrace', "#{@frames_count} frames - #{@hidden_frames_count} hidden"]
        end
      end

      def build
        @rows = @frames.map.with_index do |frame, frame_id|
          RubyJard::Row.new(
            line_limit: 2,
            columns: [
              RubyJard::Column.new(
                spans: [
                  span_frame_id(frame_id)
                ]
              ),
              RubyJard::Column.new(
                spans: [
                  span_class_label(frame),
                  span_label_preposition,
                  span_method_label(frame),
                  span_path(frame)
                ]
              )
            ]
          )
        end
      end

      private

      def span_frame_id(frame_id)
        frame_id_label = frame_id.to_s.rjust(@frames_count.to_s.length)
        if frame_id == @selected
          RubyJard::Span.new(
            content: "⮕ #{frame_id_label}",
            styles: :text_selected
          )
        else
          RubyJard::Span.new(
            content: "  #{frame_id_label}",
            styles: :text_dim
          )
        end
      end

      def span_class_label(frame)
        self_class = RubyJard::Reflection.call_class(frame.frame_self)
        class_label =
          if frame.frame_class.nil? || self_class == frame.frame_class
            if ::RubyJard::Reflection.call_is_a?(frame.frame_self, Class)
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
        RubyJard::Span.new(
          content: "#{c_frame}#{class_label}",
          margin_right: 1,
          styles: :constant
        )
      end

      def span_label_preposition
        RubyJard::Span.new(
          content: 'in',
          margin_right: 1,
          styles: :text_primary
        )
      end

      def span_method_label(frame)
        method_label =
          if frame.frame_location.label != frame.frame_location.base_label
            "#{frame.frame_location.base_label} (#{frame.frame_location.label.split(' ').first})"
          else
            frame.frame_location.base_label
          end
        RubyJard::Span.new(
          content: method_label,
          margin_right: 1,
          styles: :method
        )
      end

      def span_path(frame)
        path_label, = @path_decorator.decorate(
          frame.frame_location.path, frame.frame_location.lineno
        )
        RubyJard::Span.new(
          content: path_label,
          styles: :text_primary
        )
      end
    end
  end
end

RubyJard::Screens.add_screen('backtrace', RubyJard::Screens::BacktraceScreen)
