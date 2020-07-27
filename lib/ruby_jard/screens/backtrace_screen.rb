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
        @rows = @session.backtrace.map.with_index do |frame, frame_id|
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
            content: frame_id_label,
            styles: :backtrace_frame_id_highlighted
          )
        else
          RubyJard::Span.new(
            content: frame_id_label,
            styles: :backtrace_frame_id
          )
        end
      end

      def span_class_label(frame)
        object = frame[1]
        klass = frame[2]
        klass_label =
          if klass.nil? || object.class == klass
            if object.is_a?(Class)
              object.name
            else
              object.class.name
            end
          elsif klass.singleton_class?
            # No easy way to get the original class of a singleton class
            object.name
          else
            klass.name
          end
        c_frame = frame.last.nil? ? '[c] ' : ''
        RubyJard::Span.new(
          content: "#{c_frame}#{klass_label}",
          margin_right: 1,
          styles: :backtrace_class_label
        )
      end

      def span_label_preposition
        RubyJard::Span.new(
          content: 'in',
          margin_right: 1,
          styles: :backtrace_location
        )
      end

      def span_method_label(frame)
        location = frame[0]
        method_label =
          if location.label != location.base_label
            "#{location.base_label} (#{location.label.split(' ').first})"
          else
            location.base_label
          end
        RubyJard::Span.new(
          content: method_label,
          margin_right: 1,
          styles: :backtrace_method_label
        )
      end

      def span_path(frame)
        location = frame[0]
        decorated_path = decorate_path(location.absolute_path, location.lineno)

        path_label =
          if decorated_path.gem?
            "in #{decorated_path.gem} (#{decorated_path.gem_version})"
          else
            "at #{decorated_path.path}:#{decorated_path.lineno}"
          end
        RubyJard::Span.new(
          content: path_label,
          styles: :backtrace_location
        )
      end

      def current_frame?(frame_id)
        frame_id == current_frame
      end

      def current_frame
        if @session.frame.nil?
          0
        else
          @session.frame.pos.to_i
        end
      end

      def frames_count
        @session.backtrace.length
      end

      def decorate_path(path, lineno)
        RubyJard::Decorators::PathDecorator.new(path, lineno)
      end
    end
  end
end

RubyJard::Screens.add_screen(:backtrace, RubyJard::Screens::BacktraceScreen)
