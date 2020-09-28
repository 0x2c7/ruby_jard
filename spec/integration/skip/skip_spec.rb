# frozen_string_literal: true

RSpec.describe 'Test skip' do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/skip') }

  context 'when place jard in a nested loop' do
    it 'runs as expected' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'nested_loop.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/skip_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.send_keys('continue', :Enter)
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('skip', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('skip 2', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when place jard in a nested method calls' do
    it 'runs as expected' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'nested_method_call.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/skip_2_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('skip', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('skip 2', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when calls skip --all' do
    it 'runs as expected' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'skip_all.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/skip_2_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('skip --all', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
