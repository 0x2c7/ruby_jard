# frozen_string_literal: true

module RubyJard
  module Decorators
    ##
    # Decorator to decorate a file of source code
    # It loads a window of source code that centers the current line position.
    class SourceDecorator
      attr_reader :codes, :window_start, :window_end

      def initialize(file, lineno, window)
        @file = file
        @lineno = lineno
        @window = window
        @codes = []

        decorate
      end

      def decorate
        begin
          file = File.open(@file)
        rescue Errno::ENOENT
          return
        end

        @window_start = @lineno - @window / 2
        @window_start = 1 if @window_start <= 0
        @window_end = @window_start + @window

        until file.eof?
          loc = file.gets
          next if file.lineno < @window_start
          break if @window_end < file.lineno

          @codes << loc
        end

        file.close
      end
    end
  end
end
