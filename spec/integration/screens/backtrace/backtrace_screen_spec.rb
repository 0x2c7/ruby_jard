# frozen_string_literal: true

RSpec.describe 'Backtrace screen', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/screens/backtrace') }

  context 'when jard stops at top-level binding' do
    it 'displays top-level backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.top_level',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_2_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('next', :Enter)
      test.send_keys('step', :Enter)
      test.assert_screen
      test.send_keys('next', :Enter)
      test.send_keys('step', :Enter)
      test.assert_screen
      test.send_keys('step', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when jard stops inside an instance method' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Backtrace  4 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 Fibonaci in calculate (block)                                             │
        │    at ../../../examples/instance_method_example.rb:23                        │
        │  1 [c] Range in each at ../../../examples/instance_method_example.rb:20      │
        │  2 Fibonaci in calculate at ../../../examples/instance_method_example.rb:20  │
        │  3 Object in <main> at ../../../examples/instance_method_example.rb:32       │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.instance_method',
        "bundle exec ruby #{RSPEC_ROOT}/examples/instance_method_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when jard stops inside a class method' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Backtrace  2 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 FibonaciCalculator in calculate                                           │
        │    at ../../../examples/class_method_example.rb:19                           │
        │  1 Object in <main> at ../../../examples/class_method_example.rb:24          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.class_method',
        "bundle exec ruby #{RSPEC_ROOT}/examples/class_method_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when jard stops within a nested method' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Backtrace  8 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 DummyCalculator in calculate (block)                                      │
        │    at ../../../examples/nested_loop_example.rb:13                            │
        │  1 [c] Integer in times at ../../../examples/nested_loop_example.rb:11       │
        │  2 DummyCalculator in calculate (block)                                      │
        │    at ../../../examples/nested_loop_example.rb:11                            │
        │  3 [c] Integer in times at ../../../examples/nested_loop_example.rb:9        │
        │  4 DummyCalculator in calculate (block)                                      │
        │    at ../../../examples/nested_loop_example.rb:9                             │
        │  5 [c] Integer in times at ../../../examples/nested_loop_example.rb:7        │
        │  6 DummyCalculator in calculate at ../../../examples/nested_loop_example.rb:7│
        │  7 Object in <main> at ../../../examples/nested_loop_example.rb:20           │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.nested_method',
        "bundle exec ruby #{RSPEC_ROOT}/examples/nested_loop_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when jard stops at the beginning of file or at the end of file' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Backtrace  1 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 Object in <main> at ../../../examples/start_of_file_example.rb:2          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.end_of_file',
        "bundle exec ruby #{RSPEC_ROOT}/examples/start_of_file_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when jard steps into a code evaluation' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Backtrace  1 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 Object in <main> at ../../../examples/evaluation_example.rb:21            │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Backtrace  2 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 Object in test1 at :2                                                     │
        │  1 Object in <main> at ../../../examples/evaluation_example.rb:21            │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~'EXPECTED'
        ┌ Backtrace  2 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 Object in test2 at ../../../examples/evaluation_example.rb:14             │
        │  1 Object in <main> at ../../../examples/evaluation_example.rb:22            │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.code_evaluation',
        "bundle exec ruby #{RSPEC_ROOT}/examples/evaluation_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('step', :Enter)
      test.assert_screen
      test.send_keys('step-out', :Enter)
      test.send_keys('step', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when stop at the end of a method' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Backtrace  4 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 DummyCalculator in calculate (block)                                      │
        │    at ../../../examples/end_of_method_example.rb:10                          │
        │  1 [c] Integer in times at ../../../examples/end_of_method_example.rb:7      │
        │  2 DummyCalculator in calculate                                              │
        │    at ../../../examples/end_of_method_example.rb:7                           │
        │  3 Object in <main> at ../../../examples/end_of_method_example.rb:15         │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Backtrace  2 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 DummyCalculator in calculate                                              │
        │    at ../../../examples/end_of_method_example.rb:12                          │
        │  1 Object in <main> at ../../../examples/end_of_method_example.rb:15         │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.end_of_method',
        "bundle exec ruby #{RSPEC_ROOT}/examples/end_of_method_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when use jard with ruby -e' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Backtrace  1 frames ─────────────────────────────────────────────────────────┐
        │➠ 0 Object in <main> at :3                                                    │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.ruby_e',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 100 + 300\""
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end
end
