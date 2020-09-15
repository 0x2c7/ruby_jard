# frozen_string_literal: true

RSpec.describe 'Scenario 3: Turn on and off filter when debugging gem' do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/scenario_3') }

  it 'runs as expected' do
    test = JardIntegrationTest.new(
      self, work_dir,
      'scenario_3.expected',
      "bundle exec ruby #{RSPEC_ROOT}/integration/scenario_3/main_example.rb",
      width: 125, height: 30
    )
    test.start
    test.assert_screen
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('jard filter gems', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('step-out', :Enter)
    test.send_keys('jard filter application', :Enter)
    test.send_keys('jard filter include jard_merge_sort', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('step-out', :Enter)
    test.send_keys('jard filter clear', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('step-out', :Enter)
    test.send_keys('jard filter include securerandom', :Enter)
    test.send_keys('step', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('jard filter exclude securerandom', :Enter)
    test.assert_screen
    test.send_keys('step-out', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.send_keys('step', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('step-out', :Enter)
    test.send_keys('next', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('step-out', :Enter)
    test.send_keys('jard filter source_tree', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.send_keys('step', :Enter)
    test.assert_screen
    test.send_keys('jard filter include ../../examples/dummy_heap.rb', :Enter)
    test.assert_screen
    test.send_keys('step', :Enter)
    test.assert_screen
  ensure
    test.stop
  end
end
