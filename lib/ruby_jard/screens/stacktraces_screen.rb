# frozen_string_literal: true

module RubyJard
  module Screens
    class StacktracesScreen < RubyJard::Screen
      def draw
        @output.print TTY::Box.frame(**frame_styles)

        @output.print TTY::Cursor.move_to(@col + 2, @row)
        @output.print decorate_text
          .with_highlight(true)
          .text(" Stack trace (#{frames_count}) ", :bright_yellow)
          .content

        decorate_frames.each_with_index do |frame_texts, index|
          left, right = frame_texts
          @output.print TTY::Cursor.move_to(@col + 1, @row + index + 1)
          @output.print left.content

          if @col + left.length < @col + @layout.width - right.length - 1
            # TODO: handle reducable components in case of smaller screen
            @output.print TTY::Cursor.move_to(@col + @layout.width - right.length, @row + index + 1)
            @output.print right.content
          end
        end
      end

      private

      def data_size
        @layout.height - 1
      end

      def frame_styles
        default_frame_styles.merge(
          top: @row, left: @col, width: @layout.width, height: @layout.height
        )
      end

      def decorate_frames
        return [] if data_size.zero?

        window_start = frame_pos / data_size * data_size
        window_end = [frames_count, window_start + data_size - 1].min

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

        left =
          decorate_frame_id(frame_id, window_start, window_end) +
          ' ' +
          decorate_location_label(frame_id, location, object, klass)
        right = decorate_location_path(frame_id, location)

        [left, right]
      end

      def reset
        @color = Pastel.new
      end

      def decorate_frame_id(frame_id, window_start, window_end)
        decorate_text
          .with_highlight(frame_pos == frame_id)
          .text(frame_pos == frame_id ? '→ ' : '  ', :white)
          .text(frame_id.to_s.ljust(window_end.to_s.length), frame_pos == frame_id ? :bright_yellow : :white)
      end

      def decorate_location_label(frame_id, location, object, klass)
        decorate_text
          .with_highlight(frame_pos == frame_id)
          .text(decorate_object_label(object, klass), :green)
          .text(' in ', :white)
          .text(decorate_method_label(location), :green)
      end

      def decorate_object_label(object, klass)
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
      end

      def decorate_method_label(location)
        if location.label != location.base_label
          "#{location.base_label} (#{location.label.split(' ').first})"
        else
          location.base_label
        end
      end

      def decorate_location_path(frame_id, location)
        decorated_path = decorate_path(location.absolute_path, location.lineno)

        if decorated_path.gem?
          decorate_text
            .with_highlight(frame_pos == frame_id)
            .text('in ', :bright_white)
            .text(decorated_path.gem, :bright_white)
            .text(' (', :bright_white)
            .text(decorated_path.gem_version, :bright_white)
            .text(')', :bright_white)
        else
          decorate_text
            .with_highlight(frame_pos == frame_id)
            .text('at ', :bright_white)
            .text(decorated_path.path, :bright_white)
            .text(':', :bright_white)
            .text(decorated_path.lineno, :bright_white)
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
