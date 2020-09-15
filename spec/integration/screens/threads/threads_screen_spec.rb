# frozen_string_literal: true

RSpec.describe 'Threads screen', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/screens/threads') }

  context 'when jard stops at top-level binding' do
    it 'displays current threads' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'top_level.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when the program includes other untitled threads' do
    it 'display all untitled threads' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'threads_untitled.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/threads_untitled.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when threads have title' do
    it 'display all titled threads, sorted by name, then path' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'threads_title.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/threads_title.rb"
      )
      test.start
      sleep 0.5
      test.assert_screen

      test.send_keys('continue', :Enter)
      sleep 0.5
      test.assert_screen

      test.send_keys('continue', :Enter)
      sleep 0.5
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when there are dead threads' do
    it 'excludes all dead threads' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'threads_dead.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/threads_dead.rb"
      )
      test.start
      test.assert_screen

      test.send_keys('continue', :Enter)
      sleep 0.5
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when threads are spawn in background' do
    it 'captures all new threads' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'threads_spawn.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/threads_spawn.rb"
      )
      test.start
      test.assert_screen

      test.send_keys('continue', :Enter)
      sleep 0.5
      test.assert_screen
    ensure
      test.stop
    end
  end
end
