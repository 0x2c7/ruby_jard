# frozen_string_literal: true

RSpec.describe 'Load config file from ENV', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/placements') }

  context 'when calling jard next to jard' do
    it 'stops at next line' do
      test = JardIntegrationTest.new(
        self, work_dir, 'record.placement_1',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_1_example.rb"
      )
      test.start
      test.assert_screen
      test.stop
    end
  end

  context 'when calling print next to jard' do
    it 'stops at next line' do
      test = JardIntegrationTest.new(
        self, work_dir, 'record.placement_2',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_2_example.rb"
      )
      test.start
      test.assert_screen
      test.stop
    end
  end

  context 'when calling as a method argument' do
    it 'stops at next line' do
      test = JardIntegrationTest.new(
        self, work_dir, 'record.placement_3',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_3_example.rb"
      )
      test.start
      test.assert_screen
      test.stop
    end
  end

  context 'when calling as a string interpolation' do
    it 'stops at next line' do
      test = JardIntegrationTest.new(
        self, work_dir, 'record.placement_4',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_4_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('next', :Enter)
      test.assert_screen
      test.stop
    end
  end

  context 'when wrongly placed inside an erb' do
    it 'ignores exluded file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'record.placement_5',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_5_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('step', :Enter)
      test.assert_screen
      test.stop
    end
  end

  context 'when place jard in an ignored file' do
    it 'ignores exluded file' do
      test = JardIntegrationTest.new(
        self, work_dir, 'record.placement_6',
        "bundle exec ruby #{RSPEC_ROOT}/examples/placement_6_example.rb"
      )
      test.start
      test.assert_screen
      test.stop
    end
  end
end
