# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Display all current alive threads, excluding internal threads
    class ThreadsScreen < RubyJard::Screen
      def initialize(*args)
        super
        @current_frame_location = @session.current_frame&.frame_location
        @current_thread = @session.current_thread
        @threads = @session.threads.values

        @selected = @threads.index { |c| current_thread?(c) }
        @path_decorator = RubyJard::Decorators::PathDecorator.new
      end

      def title
        ['Threads', "#{@threads.length} threads"]
      end

      def build
        threads = sort_threads(@threads)
        @rows = threads.map do |thread|
          RubyJard::Row.new(
            line_limit: 2,
            columns: [
              RubyJard::Column.new(
                spans: [
                  span_mark(thread),
                  span_thread_label(thread)
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
      end

      private

      def span_mark(thread)
        RubyJard::Span.new(
          margin_right: 1,
          content: thread.status == 'run' ? '▸' : '•',
          styles: thread_status_style(thread)
        )
      end

      def span_thread_label(thread)
        RubyJard::Span.new(
          content: "Thread #{thread.label}",
          styles: :text_highlighted
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
          styles: :text_primary
        )
      end

      def span_thread_location(thread)
        path_label, =
          if current_thread?(thread)
            @path_decorator.decorate(
              @current_frame_location.path,
              @current_frame_location.lineno
            )
          else
            @path_decorator.decorate(
              thread.backtrace_locations[1]&.path,
              thread.backtrace_locations[1]&.lineno
            )
          end

        RubyJard::Span.new(
          content: path_label,
          styles: :text_secondary
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
        thread == @current_thread
      end

      def thread_status_style(thread)
        if thread.status == 'run'
          :text_selected
        else
          :text_dim
        end
      end
    end
  end
end

RubyJard::Screens.add_screen('threads', RubyJard::Screens::ThreadsScreen)
