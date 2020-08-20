# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Display all current alive threads, excluding internal threads
    class ThreadsScreen < RubyJard::Screen
      def title
        ['Threads', "#{@session.threads.length} threads"]
      end

      def build
        threads = sort_threads(@session.threads.values)
        @rows = threads.map do |thread|
          RubyJard::Row.new(
            line_limit: 2,
            columns: [
              RubyJard::Column.new(
                spans: [
                  span_mark(thread),
                  span_thread_id(thread)
                ]
              ),
              RubyJard::Column.new(
                spans: [
                  span_thread_status(thread)
                ]
              ),
              RubyJard::Column.new(
                spans: [
                  span_thread_name(thread),
                  span_thread_location(thread)
                ]
              )
            ]
          )
        end
        @selected = threads.index { |c| current_thread?(c) }
      end

      private

      def span_mark(thread)
        style = thread_status_style(thread)
        RubyJard::Span.new(
          margin_right: 1,
          content: style == :thread_status_run ? '►' : '•',
          styles: style
        )
      end

      def span_thread_id(thread)
        RubyJard::Span.new(
          content: "Thread #{thread.object_id}",
          styles: :thread_id
        )
      end

      def span_thread_status(thread)
        RubyJard::Span.new(
          content: "(#{thread.status})",
          styles: thread_status_style(thread)
        )
      end

      def span_thread_name(thread)
        RubyJard::Span.new(
          margin_right: 1,
          content: thread.name.nil? ? 'untitled' : thread.name,
          styles: :thread_name
        )
      end

      def span_thread_location(thread)
        return unknown_thread_location if
          thread.backtrace_locations.nil? ||
          @session.current_frame.frame_location.nil?

        last_backtrace =
          if current_thread?(thread)
            @session.current_frame.frame_location
          else
            thread.backtrace_locations[1]
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

      def sort_threads(threads)
        # Sort: current thread first
        # Sort: not debug thread first
        # Sort: not suspended thread first
        # Sort: sort by thread num
        threads.sort do |a, b|
          [
            bool_to_int(current_thread?(a)),
            bool_to_int(b.name.nil?),
            a.name,
            a.backtrace_locations[0].to_s
          ] <=> [
            bool_to_int(current_thread?(b)),
            bool_to_int(a.name.nil?),
            b.name,
            b.backtrace_locations[0].to_s
          ]
        end
      end

      def bool_to_int(bool)
        bool == true ? -1 : 1
      end

      def current_thread?(thread)
        thread == Thread.current
      end

      def decorate_path(path, lineno)
        RubyJard::Decorators::PathDecorator.new(path, lineno)
      end

      def thread_status_style(thread)
        case thread.status
        when 'run'
          :thread_status_run
        when 'sleep'
          :thread_status_sleep
        else
          :thread_status_other
        end
      end
    end
  end
end

RubyJard::Screens.add_screen('threads', RubyJard::Screens::ThreadsScreen)
