# frozen_string_literal: true

module RubyJard
  module Screens
    class ThreadsScreen < RubyJard::Screen
      def draw
        @output.print TTY::Box.frame(
          **default_frame_styles.merge(
            top: @row, left: @col, width: @width, height: @height
          )
        )

        decorated_threads = decorate_threads

        @output.print TTY::Cursor.move_to(@col + 1, @row)
        @output.print decorate_text
          .with_highlight(true)
          .text(" Threads (#{RubyJard.current_session.contexts.length}) ", :bright_yellow)
          .content

        decorated_threads.each_with_index do |thread, index|
          @output.print TTY::Cursor.move_to(@col + 1, @row + index + 1)
          @output.print thread.content
        end
      end

      private

      def data_size
        @height - 1
      end

      def decorate_threads
        contexts = sort_contexts(RubyJard.current_session.contexts)
        num_padding = contexts.length.to_s.length
        contexts.first(data_size).map do |context|
          decorate_text
            .with_highlight(current_thread?(context))
            .text(current_thread?(context) ? '→ ' : '  ', :bright_white)
            .text(context_color(context, "T#{context.thread.object_id}"))
            .with_highlight(false)
            .text(" (#{context.thread.status}) ", :white)
            .with_highlight(current_thread?(context))
            .text(thread_name(context), :bright_white)
        end
      end

      def sort_contexts(contexts)
        # Sort: current context first
        # Sort: not debug context first
        # Sort: not suspended context first
        # Sort: sort by thread num
        contexts.sort do |a, b|
          [
            bool_to_int(current_thread?(a)),
            bool_to_int(b.ignored?),
            bool_to_int(b.suspended?),
            bool_to_int(b.thread.name.nil?),
            a.thread.object_id
          ] <=> [
            bool_to_int(current_thread?(b)),
            bool_to_int(a.ignored?),
            bool_to_int(a.suspended?),
            bool_to_int(a.thread.name.nil?),
            b.thread.object_id
          ]
        end
      end

      def bool_to_int(bool)
        bool == true ? -1 : 1
      end

      def current_thread?(context)
        context.thread == Thread.current
      end

      def context_color(context, text)
        if current_thread?(context)
          decorate_text
            .with_highlight(true)
            .text(text, :bright_yellow)
        elsif context.suspended?
          decorate_text
            .with_highlight(false)
            .text(text, :red)
        elsif context.ignored?
          decorate_text
            .with_highlight(false)
            .text(text, :white)
        else
          decorate_text
            .with_highlight(false)
            .text(text, :bright_white)
        end
      end

      def thread_name(context)
        if context.thread.name.nil?
          last_backtrace =
            if context == RubyJard.current_session.current_context
              context.backtrace[0][0]
            else
              context.thread.backtrace_locations[0]
            end
          location = decorate_path(last_backtrace.path, last_backtrace.lineno)
          "#{location.path}:#{location.lineno}"
        else
          context.thread.name
        end
      end
    end
  end
end

RubyJard::Screens.add_screen(:threads, RubyJard::Screens::ThreadsScreen)
