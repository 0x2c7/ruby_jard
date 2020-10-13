# frozen_string_literal: true

RSpec.describe 'Interruption test', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/interruption') }

  context 'when press Ctrl+C when repl is idle' do
    it 'does nothing' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'idle.expected',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\""
      )
      test.start
      test.assert_screen
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.assert_screen
      test.send_keys('23', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when press Ctrl+C when repl has pending texts' do
    it 'breaks to new line' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'pending.expected',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\""
      )
      test.start
      test.assert_screen
      test.send_keys('a = 1')
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.assert_screen
      test.send_keys('23', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when press Ctrl+C during evaluation' do
    it 'breaks to new line' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'evaluation.expected',
        "bundle exec ruby -e \"require 'ruby_jard'\njard\na = 1\""
      )
      test.start
      test.assert_screen
      test.send_keys('sleep 3', :Enter)
      sleep 1
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.send_keys(:"C-c")
      test.assert_screen
      test.send_keys('23', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
