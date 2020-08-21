# frozen_string_literal: true

RSpec.describe 'Variable screen', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/screens/variables') }

  context 'when jard stops at top-level binding' do
    it 'captures all variables' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.top_level',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when jard stops at an instance method' do
    it 'captures all variables' do
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
    ensure
      test.stop
    end
  end

  context 'when jard stops inside a class method' do
    it 'captures all variables' do
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

  context 'when jard stops inside a nested loop' do
    it 'captures all variables' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.nested_loop',
        "bundle exec ruby #{RSPEC_ROOT}/examples/nested_loop_example.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'with jard jumping between methods' do
    it 'captures all variables' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.jump',
        "bundle exec ruby #{RSPEC_ROOT}/examples/instance_method_2_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('step', :Enter)
      test.assert_screen
      test.send_keys('next', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when jard steps into a code evaluation' do
    it 'displays correct line' do
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

  context 'when jard stops at the end of a method' do
    it 'displays correct line' do
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
    it 'displays correct line' do
      code = <<~CODE
        bundle exec ruby -e \"require 'ruby_jard'\njard\na = 100 + 300\nb = a + 1\"
      CODE
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.ruby_e',
        code
      )
      test.start
      test.assert_screen
      test.send_keys('next', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when jumping into an ERB file' do
    it 'displays correct line' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.erb_file',
        "bundle exec ruby #{RSPEC_ROOT}/examples/erb_evaluation.rb"
      )
      test.start
      test.assert_screen
    ensure
      test.stop
    end
  end
end
