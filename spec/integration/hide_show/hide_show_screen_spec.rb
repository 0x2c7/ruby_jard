# frozen_string_literal: true

RSpec.describe 'Hide/show screens', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/hide_show') }

  context 'when hiding/showing a screen on the top' do
    it 'strecthes the lower screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'top.expected',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\"",
        width: 130, height: 30
      )
      test.start
      test.assert_screen

      test.send_keys('jard hide variables', :Enter)
      test.assert_screen

      test.send_keys('jard hide source', :Enter)
      test.assert_screen

      test.send_keys('jard show variables', :Enter)
      test.assert_screen

      test.send_keys('jard show source', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when hiding/showing a screen on the bottom' do
    it 'strecthes the upper screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'bottom.expected',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\"",
        width: 130, height: 30
      )
      test.start
      test.assert_screen

      test.send_keys('jard hide threads', :Enter)
      test.assert_screen

      test.send_keys('jard hide backtrace', :Enter)
      test.assert_screen

      test.send_keys('jard show threads', :Enter)
      test.assert_screen

      test.send_keys('jard show backtrace', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when hiding/showing a screen not in the same column' do
    it 'strecthes the neighbor screens' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'not_same_column.expected',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\"",
        width: 130, height: 30
      )

      test.start
      test.assert_screen

      test.send_keys('jard hide threads', :Enter)
      test.send_keys('jard hide backtrace', :Enter)
      test.send_keys('jard hide source', :Enter)

      test.assert_screen
      test.send_keys('jard show source', :Enter)

      test.assert_screen
    ensure
      test.stop
    end
  end
end
