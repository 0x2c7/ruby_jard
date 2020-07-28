# frozen_string_literal: true

module RubyJard
  module Screens
    class ThreadsScreen < RubyJard::Screen
      def title
        ['Threads', "#{RubyJard.current_session.contexts.length} threads"]
      end

      def build
        contexts = RubyJard.current_session.contexts.filter { |c| c.thread.alive? }
        contexts = sort_contexts(contexts)
        @rows = contexts.map do |context|
          RubyJard::Row.new(
            line_limit: 2,
            columns: [
              RubyJard::Column.new(
                spans: [
                  span_mark(context),
                  span_thread_id(context)
                ]
              ),
              RubyJard::Column.new(
                spans: [
                  span_thread_status(context)
                ]
              ),
              RubyJard::Column.new(
                spans: [
                  span_thread_name(context),
                  span_thread_location(context)
                ]
              )
            ]
          )
        end
        @selected = contexts.index { |c| current_thread?(c) }
      end

      private

      def span_mark(context)
        RubyJard::Span.new(
          margin_right: 1,
          content: '•',
          styles: thread_status_style(context.thread)
        )
      end

      def span_thread_id(context)
        RubyJard::Span.new(
          content: "Thread #{context.thread.object_id}",
          styles: :thread_id
        )
      end

      def span_thread_status(context)
        RubyJard::Span.new(
          content: "(#{context.thread.status})",
          styles: thread_status_style(context.thread)
        )
      end

      def span_thread_name(context)
        RubyJard::Span.new(
          margin_right: 1,
          content: context.thread.name.nil? ? 'untitled' : context.thread.name,
          styles: :thread_name
        )
      end

      def span_thread_location(context)
        return unknown_thread_location if
          context.thread.backtrace_locations.nil? ||
          RubyJard.current_session.backtrace[0].nil?

        last_backtrace =
          if current_thread?(context)
            RubyJard.current_session.backtrace[0].first
          else
            context.thread.backtrace_locations[1]
          end

        return unknown_thread_location if last_backtrace.nil?

        decorated_path = decorate_path(last_backtrace.path, last_backtrace.lineno)
        if decorated_path.gem?
          RubyJard::Span.new(
            content: "in #{decorated_path.gem} (#{decorated_path.gem_version})",
            styles: :thread_location
          )
        else
          RubyJard::Span.new(
            content: "at #{decorated_path.path}:#{decorated_path.lineno}",
            styles: :thread_location
          )
        end
      end

      def unknown_thread_location
        RubyJard::Span.new(
          content: 'at ???',
          styles: :thread_location
        )
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

      def decorate_path(path, lineno)
        RubyJard::Decorators::PathDecorator.new(path, lineno)
      end

      def thread_status_style(thread)
        if thread.status == 'run'
          :thread_status_run
        elsif thread.status == 'sleep'
          :thread_status_sleep
        else
          :thread_status_other
        end
      end
    end
  end
end

RubyJard::Screens.add_screen(:threads, RubyJard::Screens::ThreadsScreen)
