# frozen_string_literal: true

RSpec.describe 'Threads screen', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/screens/threads') }

  context 'when jard stops at top-level binding' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Threads  1 threads ──────────────────────────────────────────────────────────┐
        │► Thread ?????????????? (run) untitled                                        │
        │                              at ../../../examples/top_level_example.rb:15    │
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
        │► Thread ?????????????? (run)   untitled                                      │
        │                                at ../../../examples/threads_untitled.rb:6    │
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_untitled.rb:3    │
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_untitled.rb:4    │
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
        │► Thread ?????????????? (run)   Main thread                                   │
        │                                at ../../../examples/threads_title.rb:15      │
        │• Thread ?????????????? (sleep) Test 1 at ../../../examples/threads_title.rb:6│
        │• Thread ?????????????? (sleep) Test 2 at ../../../examples/threads_title.rb:8│
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_title.rb:5       │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Threads  5 threads ──────────────────────────────────────────────────────────┐
        │► Thread ?????????????? (run)   Main thread                                   │
        │                                at ../../../examples/threads_title.rb:21      │
        │• Thread ?????????????? (sleep) Test 1 at ../../../examples/threads_title.rb:6│
        │• Thread ?????????????? (sleep) Test 2 at ../../../examples/threads_title.rb:8│
        │• Thread ?????????????? (sleep) Test 3                                        │
        │                                at ../../../examples/threads_title.rb:15      │
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_title.rb:5       │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~EXPECTED
        ┌ Threads  5 threads ──────────────────────────────────────────────────────────┐
        │► Thread ?????????????? (run)   Main thread                                   │
        │                                at ../../../examples/threads_title.rb:24      │
        │• Thread ?????????????? (sleep) Test 2 at ../../../examples/threads_title.rb:8│
        │• Thread ?????????????? (sleep) Test 3                                        │
        │                                at ../../../examples/threads_title.rb:15      │
        │• Thread ?????????????? (sleep) Test 3 at ../../../examples/threads_title.rb:6│
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_title.rb:5       │
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
        │► Thread ?????????????? (run)   Main thread                                   │
        │                                at ../../../examples/threads_dead.rb:18       │
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_dead.rb:7        │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Threads  1 threads ──────────────────────────────────────────────────────────┐
        │► Thread ?????????????? (run) Main thread                                     │
        │                              at ../../../examples/threads_dead.rb:22         │
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
        │► Thread ?????????????? (run)   Main thread                                   │
        │                                at ../../../examples/threads_spawn.rb:23      │
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_spawn.rb:8       │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Threads  6 threads ──────────────────────────────────────────────────────────┐
        │► Thread ?????????????? (run)   Main thread                                   │
        │                                at ../../../examples/threads_spawn.rb:27      │
        │• Thread ?????????????? (sleep) New thread 0                                  │
        │                                at ../../../examples/threads_spawn.rb:13      │
        │• Thread ?????????????? (sleep) New thread 1                                  │
        │                                at ../../../examples/threads_spawn.rb:13      │
        │• Thread ?????????????? (sleep) New thread 2                                  │
        │                                at ../../../examples/threads_spawn.rb:13      │
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_spawn.rb:23      │
        │• Thread ?????????????? (sleep) untitled                                      │
        │                                at ../../../examples/threads_spawn.rb:8       │
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
