# frozen_string_literal: true

RSpec.describe 'Scenario 1: Debug a simple sorting algorithm' do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/scenario_1') }

  it 'runs as expected' do
    test = JardIntegrationTest.new(
      self, work_dir,
      'record.scenario_1',
      "bundle exec ruby #{RSPEC_ROOT}/integration/scenario_1/main_example.rb",
      width: 125, height: 30
    )
    test.start
    test.assert_screen
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.assert_screen
    test.send_keys('continue', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.assert_screen
    test.send_keys('node.val', :Enter)
    test.assert_screen
    test.send_keys('next', :Enter)
    test.send_keys('final_head', :Enter)
    test.send_keys('final_tail', :Enter)
    test.assert_screen
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.assert_screen
    test.send_keys('continue', :Enter)
    test.send_keys('final_tail', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('up', :Enter)
    test.send_keys('up', :Enter)
    test.assert_screen
    test.send_keys('down', :Enter)
    sleep 1
    test.assert_screen
    test.send_keys('step-out', :Enter)
    sleep 1
    test.assert_screen
    test.send_keys('next', :Enter)
    test.send_keys('exit', :Enter)
  ensure
    test.stop
  end
end
