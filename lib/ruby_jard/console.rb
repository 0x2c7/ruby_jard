# frozen_string_literal: true

require 'tty-screen'
require 'io/console'
require 'English'

module RubyJard
  # Wrapper for utilities to control screen
  class Console
    class << self
      def attachable?
        return false if !input.tty? || !output.tty?

        width, height = screen_size(output)
        width != 0 && height != 0
      end

      def redirected?
        output != $stdout
      end

      def output
        return @output if defined?(@output)

        @output =
          if STDOUT.tty?
            STDOUT
          else
            begin
              File.open('/dev/tty', 'w+')
            rescue StandardError
              STDOUT # Give up now.
            end
          end
      end

      def input
        return @input if defined?(@input)

        @input =
          if STDIN.tty?
            STDIN
          else
            begin
              File.open('/dev/tty', 'r+')
            rescue StandardError
              STDIN # Give up.
            end
          end
      end

      def move_to(output, x, y)
        return unless output.tty?

        output.print format("\e[%<row>d;%<col>dH", row: y + 1, col: x + 1)
      end

      def screen_size(output)
        return [0, 0] unless output.tty?

        if output.respond_to?(:winsize)
          height, width = output.winsize
          [width, height]
        else
          [TTY::Screen.width, TTY::Screen.height]
        end
      end

      def clear_screen(output)
        return unless output.tty?

        output.print "\e[3J"
      end

      def clear_screen_to_end(output)
        return unless output.tty?

        output.print "\e[0J"
      end

      def disable_cursor!(output)
        return unless output.tty?

        output.print tput('civis')
      rescue RubyJard::Error
        # If tput not found, fallback to hard-coded sequence.
        output.print "\e[?25l"
      end

      def enable_cursor!(output)
        return unless output.tty?

        output.print tput('cnorm')
      rescue RubyJard::Error
        # If tput not found, fallback to hard-coded sequence.
        output.print "\e[?12l\e[?25h"
      end

      def getch(input, timeout)
        input.read_nonblock(255)
      rescue IO::WaitReadable
        io = IO.select([input], nil, nil, timeout)
        if io.nil?
          nil
        else
          retry
        end
      rescue IO::WaitWritable
        nil
      end

      def raw!(output)
        return unless output.tty?

        begin
          output.raw!
        rescue StandardError
          stty('raw')
        end
      end

      def cooked!(output)
        return unless output.tty?

        begin
          output.cooked!
        rescue StandardError
          # If stty not found, or raise error, nothing I can do
          stty('-raw')
        end
      end

      def disable_echo!(output)
        return unless output.tty?

        begin
          output.echo = false
        rescue StandardError
          # If stty not found, or raise error, nothing I can do
          stty('-echo')
        end
      end

      def enable_echo!(output)
        return unless output.tty?

        begin
          output.echo = true
        rescue StandardError
          # If stty not found, or raise error, nothing I can do
          stty('echo')
        end
      end

      def cached_tput
        @cached_tput ||= {}
      end

      def tput(*args)
        command = "tput #{args.join(' ')}"
        return cached_tput[command] unless cached_tput[command].nil?

        output = `#{command}`
        if $CHILD_STATUS.success?
          cached_tput[command] = output
        else
          raise RubyJard::Error, "Fail to call `#{command}`: #{$CHILD_STATUS}"
        end
      rescue StandardError => e
        raise RubyJard::Error, "Fail to call `#{command}`. Error: #{e}"
      end

      def stty(*args)
        command = "stty #{args.join(' ')}"
        output = `#{command}`
        if $CHILD_STATUS.success?
          output
        else
          raise RubyJard::Error, "Fail to call `#{command}`: #{$CHILD_STATUS}"
        end
      rescue StandardError => e
        raise RubyJard::Error, "Fail to call `#{command}`. Error: #{e}"
      end
    end
  end
end
