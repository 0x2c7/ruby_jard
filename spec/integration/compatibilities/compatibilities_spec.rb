# frozen_string_literal: true

RSpec.describe 'Byebug compatibility', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/compatibilities') }

  context 'when attach into program with byebug command' do
    it 'byebug command still works along with Jard' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.compatibility_byebug',
        "bundle exec ruby #{RSPEC_ROOT}/examples/byebug_example.rb",
        width: 130, height: 30
      )
      test.start
      test.assert_screen

      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when attach into program with debugger command' do
    it 'debugger command still works along with Jard' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.compatibility_debugger',
        "bundle exec ruby #{RSPEC_ROOT}/examples/debugger_example.rb",
        width: 130, height: 30
      )
      test.start
      test.assert_screen

      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when attach into program with binding.pry command' do
    it 'binding.pry command still works along with Jard' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.compatibility_binding_pry',
        "bundle exec ruby #{RSPEC_ROOT}/examples/binding_pry_example.rb",
        width: 130, height: 30
      )
      test.start
      test.assert_screen

      test.send_keys('exit', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
