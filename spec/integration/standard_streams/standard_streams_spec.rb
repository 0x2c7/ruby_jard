# frozen_string_literal: true

RSpec.describe 'Test standard_streams', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/standard_streams') }

  context 'when nothing are redirected' do
    it 'works normally' do
      test = JardIntegrationTest.new(
        self, work_dir, 'normal.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/cli.rb",
        width: 121, height: 40
      )
      test.start
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.send_keys('Quang-Minh', :Enter)
      test.send_keys('17', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('jard output', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when pipe the stdin' do
    it 'works normally' do
      test = JardIntegrationTest.new(
        self, work_dir, 'pipe_stdin.expected', 'bash',
        width: 121, height: 40
      )

      test.start
      test.send_keys("echo \"Not Minh\n19\n\" | bundle exec ruby #{RSPEC_ROOT}/examples/cli.rb", :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('jard output', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when pipe the stdout' do
    it 'works normally' do
      test = JardIntegrationTest.new(
        self, work_dir, 'pipe_stdout.expected', 'bash',
        width: 121, height: 40
      )

      test.start
      test.send_keys("bundle exec ruby #{RSPEC_ROOT}/examples/cli.rb | tail -f /dev/null", :Enter)
      sleep 1
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.send_keys('Quang-Minh', :Enter)
      test.send_keys('17', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('jard output', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when pipe both stdin and stdout' do
    it 'works normally' do
      test = JardIntegrationTest.new(
        self, work_dir, 'pipe_both_stdin_stdout.expected', 'bash',
        width: 121, height: 40
      )

      test.start
      test.send_keys(
        "echo \"Not Minh\n19\n\" | bundle exec ruby #{RSPEC_ROOT}/examples/cli.rb | tail -f /dev/null",
        :Enter
      )
      sleep 1
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('jard output', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when redirect stdout' do
    it 'works normally' do
      test = JardIntegrationTest.new(
        self, work_dir, 'redirect_stdout.expected', 'bash',
        width: 121, height: 40
      )

      test.start
      test.send_keys("bundle exec ruby #{RSPEC_ROOT}/examples/cli.rb > /dev/null", :Enter)
      sleep 1
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.send_keys('Quang-Minh', :Enter)
      test.send_keys('17', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('continue', :Enter)
      test.assert_screen
      test.send_keys('jard output', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end
end
