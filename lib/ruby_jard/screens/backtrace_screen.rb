# frozen_string_literal: true

module RubyJard
  module Screens
    ##
    # Backtrace screen implements the content to display current thread's backtrace to the user.
    class BacktraceScreen < RubyJard::Screen
      def title
        "Backtrace (#{frames_count})"
      end

      def data_size
        [@height, backtrace.length].min
      end

      def data_window
        return [] if data_size.zero?

        backtrace[data_window_start..data_window_end]
      end

      def data_window_start
        return 0 if data_size.zero?

        current_frame / data_size * data_size
      end

      def data_window_end
        [frames_count, data_window_start + data_size - 1].min
      end

      def draw
        adjust_screen_size_to_borders

        calculate
        # TODO: move this out to ScreenManager
        drawer = RubyJard::ScreenDrawer.new(output: @output)
        drawer.draw(self, @col, @row)
      end

      def span_mark(_data_row, index)
        [
          current_frame?(index) ? '→ ' : '  ',
          [:white, current_frame?(index) ? :bold : nil]
        ]
      end

      def span_frame_id(_data_row, index)
        frame_id = index + data_window_start
        [
          frame_id.to_s,
          [
            current_frame?(index) ? :bright_yellow : :white,
            current_frame?(index) ? :bold : nil
          ]
        ]
      end

      def span_klass_label(data_row, index)
        object = data_row[1]
        klass = data_row[2]
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
        c_frame = frame_at(index).last.nil? ? '[c] ' : ''
        [
          "#{c_frame}#{klass_label}",
          [:green, current_frame?(index) ? :bold : nil]
        ]
      end

      def span_label_preposition(_data_row, index)
        ['in', current_frame?(index) ? [:bright_white] : [:white]]
      end

      def span_method_label(data_row, index)
        location = data_row[0]
        method_label =
          if location.label != location.base_label
            "#{location.base_label} (#{location.label.split(' ').first})"
          else
            location.base_label
          end
        [method_label, [:green, current_frame?(index) ? :bold : nil]]
      end

      def span_path_preposition(data_row, index)
        location = data_row[0]
        decorated_path = decorate_path(location.absolute_path, location.lineno)
        preposition = decorated_path.gem? ? 'in' : 'at'
        [preposition, current_frame?(index) ? [:bright_white] : [:white]]
      end

      def span_path(data_row, index)
        location = data_row[0]
        decorated_path = decorate_path(location.absolute_path, location.lineno)

        path_label =
          if decorated_path.gem?
            "#{decorated_path.gem} (#{decorated_path.gem_version})"
          else
            "#{decorated_path.path}:#{decorated_path.lineno}"
          end
        [path_label, current_frame?(index) ? [:bold, :bright_white] : [:white]]
      end

      private

      def current_frame?(index)
        index + data_window_start == current_frame
      end

      def current_frame
        if @session.frame.nil?
          0
        else
          @session.frame.pos.to_i
        end
      end

      def frame_at(index)
        backtrace[index + data_window_start]
      end

      def frames_count
        @session.backtrace.length
      end

      def backtrace
        @session.backtrace
      end
    end
  end
end

RubyJard::Screens.add_screen(:backtrace, RubyJard::Screens::BacktraceScreen)
