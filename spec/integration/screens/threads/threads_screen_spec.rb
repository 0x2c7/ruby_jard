# frozen_string_literal: true

RSpec.describe 'Threads screen', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/screens/threads') }

  context 'when jard stops at top-level binding' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Threads  1 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run) untitled at ../../../examples/top_level_example.rb:15        │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays current threads' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
    ensure
      test.stop
    end
  end

  context 'when the program includes other untitled threads' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Threads  3 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run)   untitled at ../../../examples/threads_untitled.rb:8        │
        │• Thread 2 (sleep) untitled at ../../../examples/threads_untitled.rb:5        │
        │• Thread 3 (sleep) untitled at ../../../examples/threads_untitled.rb:6        │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'display all untitled threads' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/threads_untitled.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
    ensure
      test.stop
    end
  end

  context 'when threads have title' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Threads  4 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run)   Main thread at ../../../examples/threads_title.rb:17       │
        │• Thread 3 (sleep) Test 1 at ../../../examples/threads_title.rb:8             │
        │• Thread 4 (sleep) Test 2 at ../../../examples/threads_title.rb:10            │
        │• Thread 2 (sleep) untitled at ../../../examples/threads_title.rb:7           │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Threads  5 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run)   Main thread at ../../../examples/threads_title.rb:23       │
        │• Thread 3 (sleep) Test 1 at ../../../examples/threads_title.rb:8             │
        │• Thread 4 (sleep) Test 2 at ../../../examples/threads_title.rb:10            │
        │• Thread 5 (sleep) Test 3 at ../../../examples/threads_title.rb:17            │
        │• Thread 2 (sleep) untitled at ../../../examples/threads_title.rb:7           │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~EXPECTED
        ┌ Threads  5 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run)   Main thread at ../../../examples/threads_title.rb:26       │
        │• Thread 4 (sleep) Test 2 at ../../../examples/threads_title.rb:10            │
        │• Thread 5 (sleep) Test 3 at ../../../examples/threads_title.rb:17            │
        │• Thread 3 (sleep) Test 3 at ../../../examples/threads_title.rb:8             │
        │• Thread 2 (sleep) untitled at ../../../examples/threads_title.rb:7           │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'display all titled threads, sorted by name, then path' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/threads_title.rb")
      test.start
      sleep 0.5
      expect(test.screen_content).to match_screen(expected_output_1)

      test.send_keys('continue', :Enter)
      sleep 0.5
      expect(test.screen_content).to match_screen(expected_output_2)

      test.send_keys('continue', :Enter)
      sleep 0.5
      expect(test.screen_content).to match_screen(expected_output_3)
    ensure
      test.stop
    end
  end

  context 'when there are dead threads' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Threads  2 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run)   Main thread at ../../../examples/threads_dead.rb:20        │
        │• Thread 2 (sleep) untitled at ../../../examples/threads_dead.rb:9            │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Threads  1 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run) Main thread at ../../../examples/threads_dead.rb:24          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'excludes all dead threads' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/threads_dead.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)

      test.send_keys('continue', :Enter)
      sleep 0.5
      expect(test.screen_content).to match_screen(expected_output_2)
    ensure
      test.stop
    end
  end

  context 'when threads are spawn in background' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Threads  2 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run)   Main thread at ../../../examples/threads_spawn.rb:25       │
        │• Thread 2 (sleep) untitled at ../../../examples/threads_spawn.rb:10          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Threads  6 threads ──────────────────────────────────────────────────────────┐
        │► Thread 1 (run)   Main thread at ../../../examples/threads_spawn.rb:29       │
        │• Thread 4 (sleep) New thread 0 at ../../../examples/threads_spawn.rb:15      │
        │• Thread 5 (sleep) New thread 1 at ../../../examples/threads_spawn.rb:15      │
        │• Thread 6 (sleep) New thread 2 at ../../../examples/threads_spawn.rb:15      │
        │• Thread 2 (sleep) untitled at ../../../examples/threads_spawn.rb:10          │
        │• Thread 3 (sleep) untitled at ../../../examples/threads_spawn.rb:25          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'captures all new threads' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/threads_spawn.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)

      test.send_keys('continue', :Enter)
      sleep 0.5
      expect(test.screen_content).to match_screen(expected_output_2)
    ensure
      test.stop
    end
  end
end
