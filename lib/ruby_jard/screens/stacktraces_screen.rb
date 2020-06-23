# frozen_string_literal: true

module RubyJard
  module Screens
    class StacktracesScreen < RubyJard::Screen
      def draw
        @output.print TTY::Box.frame(**frame_styles)

        decorate_stacktraces.each_with_index do |frame_texts, index|
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
          title: { top_left: ' Stack trace ' }
        )
      end

      def decorate_stacktraces
        @session
          .backtrace
          .first(@layout.height - 2)
          .map
          .with_index do |frame, frame_id|
            decorate_frame(frame, frame_id)
          end
      end

      def decorate_frame(line, frame_id)
        path = line[0].path
        lineno = line[0].lineno

        location = line[0]
        object = line[1]
        klass = line[2]

        [
          decorate_frame_id(frame_id) + ' ' + decorate_location(frame_id, location, object, klass),
          decorate_path(frame_id, path, lineno)
        ]
      end

      def reset
        @color = Pastel.new
      end

      def decorate_frame_id(frame_id)
        padding = @session.backtrace.length.to_s.length
        decorate
          .with_highlight(current_frame?(frame_id))
          .text(current_frame?(frame_id) ? '→ ' : '  ', :white)
          .text('[', :white)
          .text(frame_id.to_s.ljust(padding), current_frame?(frame_id) ? :green : :white)
          .text(']', :white)
      end

      def decorate_location(frame_id, location, object, klass)
        klass_label, method_label =
          if klass.nil? || object.class == klass
            if object.is_a?(Class)
              [object.name, decorate_method_label(location, true)]
            else
              [object.class.name, decorate_method_label(location, false)]
            end
          else
            if klass.singleton_class?
              # No easy way to get the original class of a singleton class
              [object.name, decorate_method_label(location, true)]
            else
              [klass.name, decorate_method_label(location, false)]
            end
          end

        decorate
          .with_highlight(current_frame?(frame_id))
          .text(klass_label, :green)
          .text(' in ', :white)
          .text(method_label, :green)
      end

      def decorate_method_label(location, is_class_method)
        method_label = "#{is_class_method ? '.' : '#'}#{location.base_label}"
        if location.label != location.base_label
          "#{method_label} (#{location.label.split(' ').first})"
        else
          method_label
        end
      end

      def decorate_path(frame_id, path, lineno)
        if path.start_with?(Dir.pwd)
          path = path[Dir.pwd.length..-1]
          decorate
            .with_highlight(current_frame?(frame_id))
            .text('at ', :white)
            .text(path, :white)
            .text(':', :white)
            .text(lineno.to_s, :white)
        else
          path = pretify_gem_path(path)
          decorate
            .with_highlight(current_frame?(frame_id))
            .text('in ', :white)
            .text(path, :white)
        end
      end

      def current_frame?(frame_id)
        if @session.frame.nil?
          frame_id.zero?
        else
          frame_id == @session.frame.pos.to_i
        end
      end

      def pretify_gem_path(path)
        reducable_paths = []
        if defined?(Gem)
          Gem.path.each do |gem_path|
            reducable_paths << File.join(gem_path, 'gems')
            reducable_paths << gem_path
          end
        end
        if defined?(Bundler)
          bundle_path = Bundler.bundle_path.to_s
          reducable_paths << File.join(bundle_path, 'gems')
          reducable_paths << bundle_path
        end

        reducable_paths.each do |rp|
          next unless path.start_with?(rp)

          path = path[rp.length..-1]
          path = path[1..-1] if path.start_with?('/')

          return path.split('/').first
        end
        path
      end
    end
  end
end

RubyJard::Screens.add_screen(:stacktraces, RubyJard::Screens::StacktracesScreen)
