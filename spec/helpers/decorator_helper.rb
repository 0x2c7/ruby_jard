# frozen_string_literal: true

RSpec::Matchers.define :match_row do |expected|
  match do |actual|
    raise 'Row expected' unless actual.is_a?(RubyJard::Row)

    @expected = expected.strip
    @actual = actual.spans.map(&:content).join
    # Mask object address
    @actual.gsub!(/0x[0-9a-z]{10,}/i) { |found| '?' * found.length }
    @actual == @expected
  end

  failure_message do |actual|
    <<~SCREEN
      Expected:
      ###
      #{expected}
      ###

      Actual:
      ###
      #{actual}
      ###
    SCREEN
  end

  diffable
  attr_reader :actual, :expected
end

RSpec::Matchers.define :match_rows do |expected|
  match do |actual|
    raise 'Array of row expected' unless actual.is_a?(Array)
    raise 'Array of row expected' if !actual.empty? && !actual.all? { |r| r.is_a?(RubyJard::Row) }

    @expected = expected.strip
    @actual = actual.map { |row| row.spans.map(&:content).join }.join("\n")
    # Mask object address
    @actual.gsub!(/0x[0-9a-z]{10,}/i) { |found| '?' * found.length }
    @actual == @expected
  end

  failure_message do |actual|
    <<~SCREEN
      Expected:
      ###
      #{expected}
      ###

      Actual:
      ###
      #{actual}
      ###
    SCREEN
  end

  diffable
  attr_reader :actual, :expected
end
