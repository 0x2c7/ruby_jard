# frozen_string_literal: true

RSpec.describe 'color-scheme command', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/commands') }

  context 'when list color schemes' do
    it 'displays list of schemes' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.scheme.list',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_repl
      test.send_keys('jard color-scheme -l', :Enter)
      test.assert_repl
    ensure
      test.stop
    end
  end

  context 'when switching to new scheme' do
    it 'displays no error' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.scheme.switch',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_repl
      test.send_keys('jard color-scheme 256', :Enter)
      test.assert_repl
    ensure
      test.stop
    end
  end

  context 'when switching to not-found scheme' do
    it 'displays error' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'record.scheme.switch_not_found',
        "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb"
      )
      test.start
      test.assert_repl
      test.send_keys('jard color-scheme NotExistedScheme', :Enter)
      test.assert_repl
    ensure
      test.stop
    end
  end
end
