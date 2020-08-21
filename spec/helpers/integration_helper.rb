# frozen_string_literal: true

class JardIntegrationTest
  def self.tests
    @tests ||= []
  end

  attr_reader :source

  def initialize(dir, expected_record_file, command, width: 80, height: 24)
    @target = "TestJard#{rand(1..1000)}"
    @source = caller[0]

    @dir = dir
    @command = command

    @width = width
    @height = height

    @expected_record_file = File.join(@dir, expected_record_file)
    @expected_record = parse_expected_record(@expected_record_file)

    if recording_actual?
      @actual_record_file = File.open(File.join(@dir, "#{expected_record_file}.actual"), 'w')
    end

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
    @actual_record_file.close if recording_actual?
    JardIntegrationTest.tests.delete(self)
  end

  def assert_screen(test)
    if recording_actual?
      record_actual_screen(screen_content)
    else
      test.expect(screen_content).to test.match_screen(@expected_record.shift.to_s)
    end
  end

  def assert_repl(test)
    if recording_actual?
      record_actual_screen(screen_content)
    else
      test.expect(screen_content).to test.match_screen(@expected_record.shift.to_s)
    end
  end

  def send_keys(*args)
    record_actual_keys(args) if recording_actual?

    args.map! do |key|
      if key.is_a?(String)
        "\"#{key.gsub(/"/i, '\"')}\""
      else
        key.to_s
      end
    end
    tmux('send-keys', '-t', @target, *args)
  end

  def screen_content(allow_duplication = true)
    sleep 0.5

    previous_content = @content
    sleep 1 if previous_content.nil? && ENV['CI']

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

  def recording_actual?
    !ENV['RECORD_ACTUAL'].nil?
  end

  def record_actual_keys(keys)
    @actual_record_file.puts '### START SEND_KEYS ###'
    @actual_record_file.puts keys.inspect
    @actual_record_file.puts '### END SEND_KEYS ###'
  end

  def record_actual_screen(screen)
    @actual_record_file.puts '### START SCREEN ###'
    @actual_record_file.puts screen
    @actual_record_file.puts '### END SCREEN ###'
  end

  def parse_expected_record(path)
    return [] if recording_actual?

    file = File.open(path)
    state = nil
    buffer = []
    records = []
    file.each_line do |line|
      line = line.strip
      case line
      when '### START SEND_KEYS ###'
        raise "Invalid file. Start new session while in state #{state}" unless state.nil?

        state = :send_keys
      when '### END SEND_KEYS ###'
        raise "Invalid file. End session :send_keys while in state #{state}" unless state == :send_keys

        state = nil
      when '### START SCREEN ###'
        raise "Invalid file. Start new session while in state #{state}" unless state.nil?

        state = :screen
      when '### END SCREEN ###'
        raise "Invalid file. End session :send_keys while in state #{state}" unless state == :screen

        state = nil
        records << buffer.join("\n")
        buffer = []
      else
        buffer << line if state == :screen
      end
    end
    records
  end
end

RSpec::Matchers.define :match_screen do |expected|
  match do |actual|
    @actual =
      actual
      .split("\n")
      .map(&:strip)
      .join("\n")

    @expected =
      expected
      .split("\n")
      .map(&:strip)
      .join("\n")

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
