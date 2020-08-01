# frozen_string_literal: true

require 'securerandom'

class JardIntegrationTest
  def initialize(dir, command, width: 80, height: 24)
    @target = "TestJard#{SecureRandom.uuid}"
    @dir = dir
    @command = command
    @width = width
    @height = height
  end

  def start
    tmux(
      'new-session',
      '-d',
      '-c', @dir,
      '-s', @target,
      '-n', 'main',
      "-x #{@width}",
      "-y #{@height}",
      @command
    )
    sleep 0.5
  end

  def stop
    tmux('kill-session', '-t', @target)
  end

  def send_keys(*args)
    tmux('send-keys', '-t', @target, *args)
    sleep 0.5
  end

  def screen
    tmux('capture-pane', '-J', '-p', '-t', @target)
  end

  def screen_content
    lines =
      screen.split("\n")
            .reject { |line| line.start_with?('jard >>') }
            .reject { |line| line[1..line.length - 2].strip.empty? }

    lines.join("\n")
  end

  private

  def tmux(*args)
    command = "tmux #{args.join(' ')}"
    output = `#{command}`
    if $CHILD_STATUS.success?
      output
    else
      "Fail to call `#{command}`: #{$CHILD_STATUS}"
    end
  rescue StandardError => e
    "Fail to call `#{command}`. Error: #{e}"
  end
end

RSpec::Matchers.define :match_screen do |expected|
  match do |actual|
    @expected = expected.strip
    @actual = actual.strip
    if @expected != @actual
      actual_lines = @actual.split("\n")
      expected_lines = @expected.split("\n")
      if actual_lines.length == expected_lines.length
        matched_all = true
        expected_lines.each.with_index do |expected_line, index|
          unless match_line(expected_line, actual_lines[index])
            matched_all = false
            break
          end
        end
        matched_all
      else
        false
      end
    else
      true
    end
  end

  def match_line(expected_line, actual_line)
    return false if expected_line.length != actual_line.length

    expected_line.each_char.with_index do |char, index|
      next if char == '?'

      return false if char != actual_line[index]
    end
    true
  end

  diffable
end
