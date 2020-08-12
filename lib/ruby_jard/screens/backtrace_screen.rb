# frozen_string_literal: true

module RubyJard
  module Screens
    ##
    # Backtrace screen implements the content to display current thread's backtrace to the user.
    class BacktraceScreen < RubyJard::Screen
      def title
        ['Backtrace', "#{frames_count} frames"]
      end

      def build
        @rows = @session.current_backtrace.map.with_index do |frame, frame_id|
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
        @selected = current_frame
      end

      private

      def span_frame_id(frame_id)
        frame_id_label = frame_id.to_s.rjust(frames_count.to_s.length)
        if current_frame?(frame_id)
          RubyJard::Span.new(
            content: "➠ #{frame_id_label}",
            styles: :frame_id_highlighted
          )
        else
          RubyJard::Span.new(
            content: "  #{frame_id_label}",
            styles: :frame_id
          )
        end
      end

      def span_class_label(frame)
        class_label =
          if frame.frame_class.nil? || frame.frame_self.class == frame.frame_class
            if frame.frame_self.is_a?(Class)
              frame.frame_self.name
            else
              frame.frame_self.class.name
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
          styles: :frame_location
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
        decorated_path = decorate_path(frame.frame_location.absolute_path, frame.frame_location.lineno)

        path_label =
          if decorated_path.gem?
            "in #{decorated_path.gem} (#{decorated_path.gem_version})"
          else
            "at #{decorated_path.path}:#{decorated_path.lineno}"
          end
        RubyJard::Span.new(
          content: path_label,
          styles: :frame_location
        )
      end

      def current_frame?(frame_id)
        frame_id == current_frame
      end

      def current_frame
        if @session.current_frame.nil?
          0
        else
          @session.current_frame.pos.to_i
        end
      end

      def frames_count
        @session.current_backtrace.length
      end

      def decorate_path(path, lineno)
        RubyJard::Decorators::PathDecorator.new(path, lineno)
      end
    end
  end
end

RubyJard::Screens.add_screen(:backtrace, RubyJard::Screens::BacktraceScreen)
