# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Display all current alive threads, excluding internal threads
    class ThreadsScreen < RubyJard::Screen
      include ::RubyJard::Span::DSL

      def initialize(**args)
        super(**args)
        @current_frame_location = @session.current_frame&.frame_location
        @current_thread = @session.current_thread
        @threads = @session.threads

        @selected = @threads.index { |c| current_thread?(c) }
        @path_decorator = RubyJard::Decorators::PathDecorator.new
      end

      def title
        ['Threads', "#{@threads.length} threads"]
      end

      def build
        threads = sort_threads(@threads)
        @rows = threads.map do |thread|
          Row.new(
            Column.new(
              span_mark(thread),
              span_thread_label(thread)
            ),
            Column.new(
              span_thread_status(thread)
            ),
            Column.new(
              span_thread_name(thread),
              span_thread_location(thread)
            ),
            line_limit: 2
          )
        end
      end

      private

      def span_mark(thread)
        if thread.status == 'run'
          text_selected('▸ ')
        else
          text_dim('• ')
        end
      end

      def span_thread_label(thread)
        text_highlighted("Thread #{thread.label}")
      end

      def span_thread_status(thread)
        if thread.status == 'run'
          text_selected("(#{thread.status})")
        else
          text_dim("(#{thread.status})")
        end
      end

      def span_thread_name(thread)
        text_primary(thread.name.nil? ? 'untitled ' : "#{thread.name} ")
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
        text_primary(path_label)
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
    end
  end
end

RubyJard::Screens.add_screen('threads', RubyJard::Screens::ThreadsScreen)
