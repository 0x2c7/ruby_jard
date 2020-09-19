# frozen_string_literal: true

RSpec.describe 'Test different placement positions', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/placements') }

  context 'when calling jard next to jard' do
    it 'stops at next line' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_1.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_1_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when calling print next to jard' do
    it 'stops at next line' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_2.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_2_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when calling as a method argument' do
    it 'stops at next line' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_3.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_3_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when calling as a string interpolation' do
    it 'stops at next line' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_4.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_4_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('next', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when wrongly placed inside an erb' do
    it 'ignores exluded file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_5.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_5_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('step', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when place jard in an ignored file' do
    it 'ignores exluded file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_6.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_6_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when place jard after an or' do
    it 'stops at the next file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_7.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_7_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when place jard inside a nested print' do
    it 'stops at the next file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_8.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_8_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when calling jard from a required file inside irb' do
    it 'stops at the next file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_9.expected',
        'bundle exec irb'
      )
      test.start
      test.assert_screen
      test.send_keys('require_relative "../../examples/top_level_2_example.rb"', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when calling jard from a ignored required file inside irb' do
    it 'stops at the next file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_10.expected',
        'bundle exec irb'
      )
      test.start
      test.assert_screen
      test.send_keys('require_relative "../../examples/top_level_example.rb"', :Enter)
      test.send_keys('system("clear")', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when calling jard from a method call inside irb' do
    it 'stops at the next file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_11.expected',
        'bundle exec irb'
      )
      test.start
      test.assert_screen
      test.send_keys('require_relative "../../examples/instance_method_example.rb"', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when calling jard directly inside irb' do
    it 'stops at the next file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'placement_12.expected',
        'bundle exec irb'
      )
      test.start
      test.assert_screen
      test.send_keys('require "ruby_jard"', :Enter)
      test.send_keys('def method_a', :Enter)
      test.send_keys('  jard', :Enter)
      test.send_keys('end', :Enter)
      test.send_keys('method_a', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
