# frozen_string_literal: true

class JardIntegrationTest
  def self.tests
    @tests ||= []
  end

  attr_reader :source

  def initialize(dir, command, width: 80, height: 24)
    @target = "TestJard#{rand(1..1000)}"
    @dir = dir
    @command = command
    @width = width
    @height = height
    @source = caller[0]
    JardIntegrationTest.tests << self
  end

  def start
    tmux(
      'new-session',
      '-d',
      '-c', @dir,
      '-s', @target,
      '-n', 'blank',
      "-x #{@width}",
      "-y #{@height}"
    )
    tmux(
      'new-window',
      '-c', @dir,
      '-t', @target,
      '-n', 'main',
      @command
    )
    sleep 0.5
  end

  def stop
    tmux('kill-session', '-t', @target)
    JardIntegrationTest.tests.delete(self)
  end

  def send_keys(*args)
    args.map! do |key|
      if key.is_a?(String)
        "\"#{key.gsub(/"/i, '\"')}\""
      else
        key.to_s
      end
    end
    tmux('send-keys', '-t', @target, *args)
    sleep 0.5
  end

  def screen_content(allow_duplication = true)
    sleep 0.5

    previous_content = @content
    sleep 3 if previous_content.nil? && ENV['CI']

    attempt = 5
    loop do
      @content = tmux('capture-pane', '-J', '-p', '-t', @target)
      break if attempt <= 0
      break unless @content.to_s.strip.empty?

      attempt -= 1
      sleep 0.5

      puts "\t# Fai to capture pane. Retrying..."
    end

    attempt = 5
    loop do
      @content = tmux('capture-pane', '-J', '-p', '-t', @target)
      break if allow_duplication
      break if attempt <= 0
      break if @content != previous_content

      attempt -= 1
      sleep 0.5

      puts "\t# Pane content seems to be different from previous capture. Retrying..."
    end
    @content
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
    @raw = actual
    actual =
      actual
      .split("\n")
      .reject { |line| line.strip.include?('jard >>') }
      .reject { |line| line[1..line.length - 2]&.strip&.empty? }
      .join("\n")

    @expected = expected.strip
    @actual = actual.strip
    if @expected != @actual
      match_content(@expected, @actual)
    else
      true
    end
  end

  failure_message do |actual|
    <<~SCREEN
      Expected screen:
      ###
      #{expected}
      ###

      Actual screen:
      ###
      #{actual}
      ###
    SCREEN
  end

  def match_content(expected, actual)
    actual_lines = actual.split("\n")
    expected_lines = expected.split("\n")
    return false unless actual_lines.length == expected_lines.length

    actual_title = actual_lines.shift
    expected_title = expected_lines.shift

    return false unless match_title(expected_title, actual_title)

    matched_all = true
    expected_lines.each.with_index do |expected_line, index|
      unless match_line(expected_line, actual_lines[index])
        matched_all = false
        break
      end
    end
    matched_all
  end

  def match_title(expected_title, actual_title)
    box_lines.each do |char|
      expected_title.to_s.gsub!(/#{char}/, ' ')
      actual_title.to_s.gsub!(/#{char}/, ' ')
    end
    expected_title.strip == actual_title.strip
  end

  def match_line(expected_line, actual_line)
    return false if expected_line.length != actual_line.length

    expected_line.each_char.with_index do |char, index|
      next if char == '?'

      return false if char != actual_line[index]
    end
    true
  end

  def box_lines
    [
      RubyJard::BoxDrawer::NORMALS_CORNERS.values,
      RubyJard::BoxDrawer::OVERLAPPED_CORNERS.values,
      RubyJard::BoxDrawer::HORIZONTAL_LINE,
      RubyJard::BoxDrawer::VERTICAL_LINE,
      RubyJard::BoxDrawer::CROSS_CORNER
    ].flatten
  end

  diffable
end

RSpec::Matchers.define :match_repl do |expected|
  match do |actual|
    actual =
      actual
      .split("\n")
      .map(&:strip)
      .join("\n")
    @expected = expected.strip
    @actual = actual.strip
    if @expected != @actual
      match_content(@expected, @actual)
    else
      true
    end
  end

  failure_message do |actual|
    <<~SCREEN
      Expected screen:
      ###
      #{expected}
      ###

      Actual screen:
      ###
      #{actual}
      ###
    SCREEN
  end

  def match_content(expected, actual)
    actual_lines = actual.split("\n")
    expected_lines = expected.split("\n")
    return false unless actual_lines.length == expected_lines.length

    matched_all = true
    expected_lines.each.with_index do |expected_line, index|
      unless match_line(expected_line.strip, actual_lines[index].strip)
        matched_all = false
        break
      end
    end
    matched_all
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
