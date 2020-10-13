# frozen_string_literal: true

RSpec.describe 'Debugging multi-threads', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/threads') }

  context 'when two threads are attaching' do
    it 'attaches one thread, and hold another thread' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'on_hold.expected',
        'bundle exec ruby ../../examples/multithread_example.rb'
      )
      test.start
      test.assert_screen
      test.send_keys('a', :Enter)
      test.send_keys('b', :Enter)
      test.send_keys('a + b', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('a', :Enter)
      test.send_keys('b', :Enter)
      test.send_keys('a + b', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
