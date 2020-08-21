# frozen_string_literal: true

RSpec.describe 'Scenario 2: Debug a simple gem' do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/scenario_2') }

  it 'is correct' do
    test = JardIntegrationTest.new(
      self, work_dir,
      'record.scenario_2',
      "bundle exec ruby #{RSPEC_ROOT}/integration/scenario_2/main_example.rb",
      width: 125, height: 30
    )
    test.start
    test.assert_screen
    test.send_keys('step', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('step-out', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.assert_screen
    test.send_keys('up', :Enter)
    test.send_keys('array', :Enter)
    test.send_keys('array[mid..array.length - 1]', :Enter)
    test.assert_screen
    test.send_keys('down', :Enter)
    test.send_keys('next', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('step-out', :Enter)
    test.assert_screen
    test.send_keys('next', :Enter)
    test.send_keys('step', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('next', :Enter)
    test.assert_screen
    test.send_keys('step-out', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.send_keys('less.call(1, 3)', :Enter)
    test.send_keys('less.call(100, 99)', :Enter)
    test.assert_screen
    test.send_keys('list', :Enter)
    test.assert_screen
    test.send_keys('step-out', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('jard output', :Enter)
    test.assert_screen
    test.send_keys('q', :Enter)
    test.send_keys('continue', :Enter)
  ensure
    test.stop
  end
end
