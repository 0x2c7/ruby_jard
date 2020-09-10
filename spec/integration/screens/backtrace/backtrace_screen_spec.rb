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
    it 'displays correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.code_evaluation',
        "bundle exec ruby #{RSPEC_ROOT}/examples/evaluation_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('jard filter everything', :Enter)
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
        │⮕ 0 Object in <main> at :3                                                    │
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

  context 'when working with Basic Object' do
    it 'display correct backtrace inside basic object' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.basic_object',
        "bundle exec ruby #{RSPEC_ROOT}/examples/basic_object_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('step', :Enter)
      test.assert_screen
      test.send_keys('step', :Enter)
      test.send_keys('step', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when explore the backtrace with filter on/off' do
    it 'display correct backtrace' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.explore_filter_on_off',
        "bundle exec ruby #{RSPEC_ROOT}/examples/sort_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('step', :Enter)
      test.assert_screen
      test.send_keys('up', :Enter)
      test.assert_screen
      test.send_keys('up', :Enter)
      test.assert_screen
      test.send_keys('down 2', :Enter)
      test.assert_screen

      test.send_keys('jard filter gems', :Enter)
      test.assert_screen
      test.send_keys('up', :Enter)
      test.send_keys('up', :Enter)
      test.send_keys('up', :Enter)
      test.send_keys('up', :Enter)
      test.assert_screen
      test.send_keys('up 4', :Enter)
      test.assert_screen

      test.send_keys('frame 2', :Enter)
      test.assert_screen
      test.send_keys('frame 7', :Enter)
      test.assert_screen

      test.send_keys('jard filter application', :Enter)
      test.assert_screen
      test.send_keys('frame 2', :Enter)
      test.assert_screen
      test.send_keys('down', :Enter)
      test.assert_screen
      test.send_keys('jard filter gems', :Enter)
      test.send_keys('frame 2', :Enter)
      test.send_keys('jard filter application', :Enter)
      test.assert_screen
      test.send_keys('up', :Enter)
      test.assert_screen

      test.send_keys('continue', :Enter)

      test.send_keys('step', :Enter)
      test.send_keys('step', :Enter)
      test.send_keys('step', :Enter)
      test.assert_screen
      test.send_keys('jard filter everything', :Enter)
      test.send_keys('step', :Enter)
      test.assert_screen
      test.send_keys('frame 10', :Enter)
      test.assert_screen
      test.send_keys('frame 7', :Enter)
      test.assert_screen
      test.send_keys('up', :Enter)
      test.assert_screen
      test.send_keys('down', :Enter)
      test.assert_screen

      test.send_keys('jard filter application', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
