# frozen_string_literal: true

RSpec.describe 'Auto layout', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/auto_layout') }

  context 'when the window is enormous' do
    it 'picks wide layout' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.enormous',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\"",
        width: 121, height: 30
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when the window can only fit 1 screen' do
    it 'picks tiny layout' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.tiny',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\"",
        width: 30, height: 30
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when the screen is short, but wide' do
    it 'picks narrow horizontal layout' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.horizontal',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\"",
        width: 130, height: 15
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when the screen is tall, but narrow' do
    it 'picks narrow vertical layout' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.vertical',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\"",
        width: 50, height: 50
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end
end
