# frozen_string_literal: true

RSpec.describe 'Default key bindings', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/key_bindings') }

  context 'with switch filter binding' do
    it 'strecthes the lower screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.filter_key_bindings',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys(:F2)
      test.assert_screen
      test.send_keys(:F2)
      test.assert_screen
      test.send_keys(:F2)
      test.assert_screen
      test.send_keys(:F2)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'with next and step bindings' do
    it 'strecthes the lower screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.next_step_key_bindings',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_2_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys(:F8)
      test.assert_screen
      test.send_keys(:F8)
      test.assert_screen
      test.send_keys(:F7)
      test.assert_screen
      test.send_keys(:F7)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'with step/step-out bindings' do
    it 'strecthes the lower screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.step_step_out_key_bindings',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_2_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys(:F7)
      test.assert_screen
      test.send_keys(:F7)
      test.assert_screen
      test.send_keys(:"S-F7")
      test.assert_screen
      test.send_keys(:F7)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'with up/down bindings' do
    it 'strecthes the lower screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.up_down_key_bindings',
        "bundle exec ruby #{RSPEC_ROOT}/examples/nested_loop_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys(:F7)
      test.assert_screen
      test.send_keys(:F6)
      test.assert_screen
      test.send_keys(:F6)
      test.assert_screen
      test.send_keys(:"S-F6")
      test.assert_screen
      test.send_keys(:"S-F6")
      test.assert_screen
      test.send_keys(:F8)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'with continue bindings' do
    it 'strecthes the lower screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.continue_key_bindings',
        "bundle exec ruby #{RSPEC_ROOT}/examples/instance_method_2_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys(:F9)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'with list bindings' do
    it 'strecthes the lower screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.list_key_bindings',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys(:F5)
      test.assert_screen
      test.send_keys(:F5)
      test.assert_screen
      test.send_keys(:F5)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
