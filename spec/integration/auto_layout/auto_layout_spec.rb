# frozen_string_literal: true

RSpec.describe 'Auto layout', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/auto_layout') }

  context 'when the window is enormous' do
    it 'picks wide layout' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'enormous.expected',
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
        'tiny.expected',
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
        'horizontal.expected',
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
        'vertical.expected',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\"",
        width: 50, height: 50
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when a window is resized' do
    it 'resizes and choose a right layout' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'resize.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_screen
      test.resize(50, 60)
      test.assert_screen
      test.resize(50, 40)
      test.assert_screen
      test.resize(121, 30)
      test.assert_screen
      test.resize(121, 20)
      test.assert_screen
      test.resize(100, 50)
      test.assert_screen
      test.resize(140, 70)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when a window is resized during evaluation' do
    it 'defers the resizing event until finish' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'resize_evaluation.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('3.times { sleep 1 }', :Enter)
      sleep 1
      test.resize(50, 60)
      sleep 3
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when a window is resized multiple time' do
    it 'ignores the sequential resizing event' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'resize_multiple.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('3.times { sleep 1 }', :Enter)
      sleep 1
      test.resize(50, 60)
      test.resize(50, 62)
      test.resize(50, 63)
      sleep 3
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when there is input during evaluation after resize event' do
    it 'repeat output after resize events' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'resize_output.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_screen
      # rubocop:disable Lint/InterpolationCheck
      test.send_keys('puts "Input before"; 3.times { |i| sleep 1; puts "Input #{i}" }', :Enter)
      # rubocop:enable Lint/InterpolationCheck
      sleep 0.5
      test.resize(50, 60)
      test.resize(50, 62)
      test.resize(50, 63)
      sleep 4
      test.assert_screen
    ensure
      test.stop
    end
  end
end
