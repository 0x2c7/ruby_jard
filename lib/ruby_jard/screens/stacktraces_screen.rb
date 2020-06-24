# frozen_string_literal: true

module RubyJard
  module Screens
    class StacktracesScreen < RubyJard::Screen
      def draw
        @output.print TTY::Box.frame(**frame_styles)

        decorate_frames.each_with_index do |frame_texts, index|
          left, right = frame_texts
          @output.print TTY::Cursor.move_to(@col + 1, @row + index + 1)
          @output.print left.content

          @output.print TTY::Cursor.move_to(@col + @layout.width - right.length - 1, @row + index + 1)
          @output.print right.content
        end
      end

      private

      def frame_styles
        default_frame_styles.merge(
          top: @row, left: @col, width: @layout.width, height: @layout.height,
          title: { top_left: " Stack trace (#{frames_count})" }
        )
      end

      def decorate_frames
        data_size = @layout.height - 1
        return [] if data_size.zero?

        window_start = frame_pos / data_size * data_size
        window_end = window_start + data_size

        frames[window_start..window_end]
          .map
          .with_index do |frame, frame_index|
            decorate_frame(frame, window_start + frame_index, window_start, window_end)
          end
      end

      def decorate_frame(line, frame_id, window_start, window_end)
        location = line[0]
        object = line[1]
        klass = line[2]

        [
          decorate_frame_id(frame_id, window_start, window_end) + ' ' +
            decorate_location_label(frame_id, location, object, klass),
          decorate_location_path(frame_id, location)
        ]
      end

      def reset
        @color = Pastel.new
      end

      def decorate_frame_id(frame_id, window_start, window_end)
        decorate_text
          .with_highlight(frame_pos == frame_id)
          .text(frame_pos == frame_id ? '→ ' : '  ', :white)
          .text('[', :white)
          .text(frame_id.to_s.ljust(window_end.to_s.length), frame_pos == frame_id ? :green : :white)
          .text(']', :white)
      end

      def decorate_location_label(frame_id, location, object, klass)
        object_label, is_class_method = analyze_object(object, klass)

        decorate_text
          .with_highlight(frame_pos == frame_id)
          .text(object_label, :green)
          .text(' in ', :white)
          .text(decorate_method_label(location, is_class_method), :green)
      end

      def analyze_object(object, klass)
        if klass.nil? || object.class == klass
          if object.is_a?(Class)
            [object.name, true]
          else
            [object.class.name, false]
          end
        elsif klass.singleton_class?
          # No easy way to get the original class of a singleton class
          [object.name, true]
        else
          [klass.name, false]
        end
      end

      def decorate_method_label(location, is_class_method)
        method_label = "#{is_class_method ? '.' : '#'}#{location.base_label}"
        if location.label != location.base_label
          "#{method_label} (#{location.label.split(' ').first})"
        else
          method_label
        end
      end

      def decorate_location_path(frame_id, location)
        decorated_path = decorate_path(location)

        if decorated_path.gem?
          decorate_text
            .with_highlight(frame_pos == frame_id)
            .text('in ', :white)
            .text(decorated_path.gem, :white)
        else
          decorate_text
            .with_highlight(frame_pos == frame_id)
            .text('at ', :white)
            .text(decorated_path.path, :white)
            .text(':', :white)
            .text(decorated_path.lineno, :white)
        end
      end

      def frame_pos
        if @session.frame.nil?
          0
        else
          @session.frame.pos.to_i
        end
      end

      def frames_count
        @session.backtrace.length
      end

      def frames
        @session.backtrace
      end
    end
  end
end

RubyJard::Screens.add_screen(:stacktraces, RubyJard::Screens::StacktracesScreen)
