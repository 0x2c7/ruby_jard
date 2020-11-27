# frozen_string_literal: true

RSpec.describe 'Byebug compatibility', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/compatibilities') }

  context 'when attach into program with byebug command' do
    it 'byebug command still works along with Jard' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'compatibility_byebug.expected',
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
        'compatibility_debugger.expected',
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
        'compatibility_binding_pry.expected',
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

  context 'when attach into program with mixed binding.pry and jard command' do
    it 'binding.pry command still works along with Jard' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'compatibility_binding_pry_mixed.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/binding_pry_mixed_example.rb",
        width: 130, height: 30
      )
      test.start
      test.assert_screen

      test.send_keys('continue', :Enter)
      test.assert_screen

      test.send_keys('exit', :Enter)
      test.assert_screen

      test.send_keys('continue', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
