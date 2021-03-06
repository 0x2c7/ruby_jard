# frozen_string_literal: true

RSpec.describe 'Variable screen', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/screens/variables') }

  context 'when jard stops at top-level binding' do
    it 'captures all variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'top_level.expected',
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
  end

  context 'when jard stops at an instance method' do
    it 'captures all variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'instance_method.expected',
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
  end

  context 'when jard stops inside a class method' do
    it 'captures all variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'class_method.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/class_method_example.rb"
        )
        test.start
        test.assert_screen
      ensure
        test.stop
      end
    end
  end

  context 'when jard stops inside a nested loop' do
    it 'captures all variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'nested_loop.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/nested_loop_example.rb"
        )
        test.start
        test.assert_screen
      ensure
        test.stop
      end
    end
  end

  context 'with jard jumping between methods' do
    it 'captures all variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'jump.expected',
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
  end

  context 'when jard steps into a code evaluation' do
    it 'display relevant variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'code_evaluation.expected',
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
  end

  context 'when jard stops at the end of a method' do
    it 'display relevant variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'end_of_method.expected',
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
  end

  context 'when use jard with ruby -e' do
    it 'display relevant variables' do
      begin
        code = <<~CODE
          bundle exec ruby -e \"require 'ruby_jard'\njard\na = 100 + 300\nb = a + 1\"
        CODE
        test = JardIntegrationTest.new(
          self, work_dir,
          'ruby_e.expected',
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
  end

  context 'when jumping into an ERB file' do
    it 'display relevant variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'erb_file.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/erb_evaluation.rb"
        )
        test.start
        test.assert_screen
      ensure
        test.stop
      end
    end
  end

  context 'when constants come from different sources' do
    it 'display relevant constant and global variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'complicated_constant.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/complicated_constant_example.rb"
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
  end

  context 'when instance variables come from different sources' do
    it 'display relevant instance variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'complicated_instance.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/complicated_instance_example.rb"
        )
        test.start
        test.assert_screen
        test.send_keys('continue', :Enter)
        test.assert_screen
        test.send_keys('continue', :Enter)
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
  end

  context 'when working with Basic Object' do
    it 'display relevant instance variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'basic_object.expected',
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
  end

  context 'when working with circular reference object' do
    it 'display relevant instance variables' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'circular_reference.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/circular_reference_example.rb"
        )
        test.start
        test.assert_screen
        test.send_keys('continue', :Enter)
        test.assert_screen
      ensure
        test.stop
      end
    end
  end
end
