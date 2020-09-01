# frozen_string_literal: true

RSpec::Matchers.define :match_spans do |expected|
  match do |actual|
    @expected = expected.strip
    @actual =
      if actual.is_a?(Array) && actual[0].is_a?(Array)
        actual.map { |line| line.map(&:content).join }.join("\n")
      elsif actual.is_a?(Array)
        actual.map(&:content).join
      else
        actual.content
      end
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
