# frozen_string_literal: true

module RubyJard
  module Screens
    class ThreadsScreen < RubyJard::Screen
      def title
        ['Threads', "#{RubyJard.current_session.contexts.length} threads"]
      end

      def data_size
        [@height, RubyJard.current_session.contexts.length].min
      end

      def data_window
        return @data_window if defined?(@data_window)

        contexts = RubyJard.current_session.contexts.filter { |c| c.thread.alive? }
        @data_window ||= sort_contexts(contexts).first(data_size)
      end

      def span_mark(context, _index)
        [
          current_thread?(context) ? '→' : ' ',
          [:bright_yellow, current_thread?(context) ? :bold : nil]
        ]
      end

      def span_thread_id(context, _index)
        [
          context.thread.object_id.to_s,
          [:green, current_thread?(context) ? :bold : nil]
        ]
      end

      def span_thread_status(context, _index)
        status_color =
          if context.suspended?
            :red
          elsif context.ignored?
            :white
          elsif context.thread.status == 'run'
            :green
          else
            :white
          end
        [
          "(#{context.thread.status})",
          [status_color, current_thread?(context) ? :bold : nil]
        ]
      end

      def span_thread_name(context, _index)
        if context.thread.name.nil?
          last_backtrace = context.thread.backtrace_locations[1]
          location = decorate_path(last_backtrace.path, last_backtrace.lineno)
          ["#{location.path}:#{location.lineno}", current_thread?(context) ? [:bright_white, :bold] : :white]
        else
          name = context.thread.name.to_s
          [name, current_thread?(context) ? [:bright_white, :bold] : :white]
        end
      end

      private

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

      def decorate_path(path, lineno)
        RubyJard::Decorators::PathDecorator.new(path, lineno)
      end
    end
  end
end

RubyJard::Screens.add_screen(:threads, RubyJard::Screens::ThreadsScreen)
