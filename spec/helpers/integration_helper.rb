# frozen_string_literal: true

require 'securerandom'

class JardIntegrationTest
  def self.tests
    @tests ||= []
  end

  attr_reader :source

  def initialize(test, dir, expected_record_file, command, width: 80, height: 24)
    @target = "TestJard#{SecureRandom.uuid}"
    @test = test
    @source = caller[0]

    @dir = dir
    @command = command

    @width = width
    @height = height

    @expected_record_file = File.join(@dir, expected_record_file)
    @expected_record = parse_expected_record(@expected_record_file)

    if recording_actual?
      @actual_record_file = File.open(File.join(@dir, "#{expected_record_file.gsub('.expected', '')}.actual"), 'w')
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

  def resize(width, height)
    @width = width
    @height = height
    tmux(
      'resize-window',
      '-t', @target,
      '-x', @width.to_s,
      '-y', @height.to_s
    )
    sleep 1

    record_resize(width, height) if recording_actual?
  end

  def stop
    # Kill active pid in the pane to prevent trashing the system after rspec finishes
    begin
      pids = tmux('list-panes', '-t', @target, '-F', '\\#\{pane_pid\}')
      pids.split("\n").map(&:strip).each { |pid| `kill #{pid}` if !pid.nil? && !pid.empty? }
    rescue StandardError
      # Ignore
    end

    begin
      tmux('kill-session', '-t', @target)
    rescue StandardError
      # Ignore
    end

    JardIntegrationTest.tests.delete(self)

    if recording_actual?
      @actual_record_file.close
      @test.pending
      @test.send :fail, 'Recording actual screen...'
    end
  end

  def assert_screen
    if recording_actual?
      record_actual_screen(screen_content)
    else
      content, line = *(@expected_record.shift || [])
      @test.expect(screen_content).to @test.match_screen(content.to_s, line)
    end
  end

  def assert_screen_include(str)
    if recording_actual?
      record_actual_screen('')
    else
      _content, _line = *(@expected_record.shift || [])
      @test.expect(screen_content).to @test.include(str)
    end
  end

  def assert_screen_not_include(str)
    if recording_actual?
      record_actual_screen('')
    else
      _content, _line = *(@expected_record.shift || [])
      @test.expect(screen_content).not_to @test.include(str)
    end
  end

  def skip_screen
    if recording_actual?
      record_actual_screen('')
    else
      _content, _line = *(@expected_record.shift || [])
    end
  end

  def send_keys(*args)
    record_actual_keys(args) if recording_actual?

    args.each do |key|
      if key.is_a?(String)
        key = "\"#{key.gsub(/"/i, '\"')}\""
        tmux('send-keys', '-t', @target, '-l', key)
      else
        tmux('send-keys', '-t', @target, key.to_s)
      end
    end

    sleep 0.5
  end

  def screen_content(allow_duplication = true)
    sleep 0.5

    previous_content = @content
    sleep 1 if previous_content.nil? && ENV['CI']

    attempt = 5
    loop do
      @content = capture_pane
      break if attempt <= 0
      break unless @content.to_s.strip.empty?

      attempt -= 1
      sleep 0.5
    end

    attempt = 5
    loop do
      @content = capture_pane
      break if allow_duplication
      break if attempt <= 0
      break if @content != previous_content

      attempt -= 1
      sleep 0.5
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
      raise "Fail to call `#{command}`. Status: #{$CHILD_STATUS}. Output: #{output}"
    end
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
    @actual_record_file.puts mark_screen(screen)
    @actual_record_file.puts '### END SCREEN ###'
  end

  def record_resize(width, height)
    @actual_record_file.puts '### START RESIZE ###'
    @actual_record_file.puts "Resize to #{width}, #{height}"
    @actual_record_file.puts '### END RESIZE ###'
  end

  def mark_screen(screen)
    screen.gsub(/0x[0-9a-z]{10,}/i) { |found| '?' * found.length }
  end

  def parse_expected_record(path)
    return [] if recording_actual?

    file = File.open(path)
    state = nil
    buffer = []
    records = []
    lineno = nil
    file.each_line.with_index do |line, index|
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
        lineno = index + 1
      when '### END SCREEN ###'
        raise "Invalid file. End session :send_keys while in state #{state}" unless state == :screen

        records << [buffer.join("\n"), lineno]
        buffer = []

        state = nil
      else
        buffer << line if state == :screen
      end
    end
    records
  end

  def capture_pane
    tmux('capture-pane', '-J', '-p', '-t', @target)
      .split("\n")
      .map { |line| line.length > @width ? line.chars.each_slice(@width).map(&:join) : line }
      .flatten
      .first(@height)
      .join("\n")
  end
end

RSpec::Matchers.define :match_screen do |expected, line|
  match do |actual|
    @line = line
    @actual =
      actual
      .split("\n")
      .map(&:strip)
      .reject(&:empty?)
      .join("\n")

    @expected =
      expected
      .split("\n")
      .map(&:strip)
      .reject(&:empty?)
      .join("\n")

    if @expected != @actual
      match_content(@expected, @actual)
    else
      true
    end
  end

  failure_message do |actual|
    <<~SCREEN
      Expected screen (line #{@line}):
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
      unless match_line(expected_line, actual_lines[index])
        matched_all = false
        break
      end
    end
    matched_all
  end

  def match_line(expected_line, actual_line)
    expected_line.each_char.with_index do |char, index|
      next if char == '?'

      return false if char != actual_line[index]
    end
    true
  end

  diffable
  attr_reader :actual, :expected
end
