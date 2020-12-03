# frozen_string_literal: true

RSpec.describe 'Custom key bindings', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/custom_key_bindings') }

  it 'supports custom key binding in the configuration file' do
    test = JardIntegrationTest.new(
      self, work_dir,
      'custom_key_bindings.expected',
      "bundle exec ruby #{RSPEC_ROOT}/examples/complicated_instance_example.rb"
    )
    test.start
    test.assert_screen
    test.send_keys(:"C-M-n") # Next
    test.assert_screen
    test.send_keys(:"C-M-n") # Next
    test.send_keys(:"M-d") # Step
    test.assert_screen
    test.send_keys(:"C-F1") # Up
    test.assert_screen
    test.send_keys(:"C-S-F1") # Down
    test.assert_screen
    test.send_keys(:"M-o") # Step out
    test.assert_screen
    test.send_keys(:"M-F1") # Continue
    test.assert_screen
    test.send_keys(:"M-S-F1") # Continue too
    test.assert_screen
    test.send_keys('hello') # Continue too
    test.assert_screen
    test.send_keys(:"M-l") # List
    test.assert_screen
    test.send_keys(:"C-n") # Switch
    test.assert_screen
  ensure
    test.stop
  end
end
