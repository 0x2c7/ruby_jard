# frozen_string_literal: true

require 'tty-screen'
require 'io/console'
require 'English'

module RubyJard
  # Wrapper for utilities to control screen
  # TODO: Write tests for this file
  class Console
    def self.instance
      @instance ||= new
    end

    attr_reader :input, :output

    def initialize
      @input =
        if STDIN.tty?
          STDIN.dup
        else
          begin
            File.open('/dev/tty', 'r+')
          rescue StandardError
            STDIN.dup # Give up.
          end
        end

      @output =
        if STDOUT.tty?
          @redirected = false
          STDOUT.dup
        else
          begin
            @redirected = true
            File.open('/dev/tty', 'w+')
          rescue StandardError
            @redirected = false
            STDOUT.dup # Give up now.
          end
        end
    end

    def print(*args)
      @output.print(*args)
    end

    def puts(*args)
      @output.puts(*args)
    end

    def write(*args)
      @output.write(*args)
    end

    def attachable?
      return false unless @output.tty?

      width, height = screen_size
      width != 0 && height != 0
    end

    def redirected?
      @redirected == true
    end

    def move_to(x, y)
      return unless @output.tty?

      @output.print format("\e[%<row>d;%<col>dH", row: y + 1, col: x + 1)
    end

    def screen_size
      return [0, 0] unless @output.tty?

      if @output.respond_to?(:winsize)
        height, width = @output.winsize
        [width, height]
      else
        [TTY::Screen.width, TTY::Screen.height]
      end
    end

    def clear_screen
      return unless @output.tty?

      @output.print "\e[3J"
    end

    def clear_screen_to_end
      return unless @output.tty?

      @output.print "\e[0J"
    end

    def disable_cursor!
      return unless @output.tty?

      @output.print tput('civis')
    rescue RubyJard::Error
      # If tput not found, fallback to hard-coded sequence.
      @output.print "\e[?25l"
    end

    def enable_cursor!
      return unless @output.tty?

      @output.print tput('cnorm')
    rescue RubyJard::Error
      # If tput not found, fallback to hard-coded sequence.
      @output.print "\e[?12l\e[?25h"
    end

    def getch(timeout)
      @input.read_nonblock(255)
    rescue IO::WaitReadable
      io = IO.select([@input], nil, nil, timeout)
      if io.nil?
        nil
      else
        retry
      end
    rescue IO::WaitWritable
      nil
    end

    def raw!
      return unless @output.tty?

      begin
        @output.raw!
      rescue StandardError
        stty('raw')
      end
    end

    def cooked!
      return unless @output.tty?

      begin
        @output.cooked!
      rescue StandardError
        # If stty not found, or raise error, nothing I can do
        stty('-raw')
      end
    end

    def disable_echo!
      return unless @output.tty?

      begin
        @output.echo = false
      rescue StandardError
        # If stty not found, or raise error, nothing I can do
        stty('-echo')
      end
    end

    def enable_echo!
      return unless @output.tty?

      begin
        @output.echo = true
      rescue StandardError
        # If stty not found, or raise error, nothing I can do
        stty('echo')
      end
    end

    def cached_tput
      @cached_tput ||= {}
    end

    # TODO: tput should affect fd of @input/@output only
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

    # TODO: stty should affect fd of @input/@output only
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
