# frozen_string_literal: true

RSpec.describe 'Output Integration tests', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/commands') }

  context 'when there is no output yet' do
    it 'displays empty pager' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'show_output.no_output.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/program_output_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('jard output', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when there the output fits into the screen' do
    it 'displays full pager stopping at the end of file' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'show_output.fit.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/program_output_example.rb"
      )
      test.start
      test.assert_screen
      test.send_keys('next', :Enter)
      test.send_keys('jard output', :Enter)
      test.assert_screen
    ensure
      test.stop
    end
  end

  context 'when there the output overflow the screen' do
    it 'displays interactive pager fit into the screen' do
      test = JardIntegrationTest.new(
        self, work_dir,
        'show_output.overflow.expected',
        "bundle exec ruby #{RSPEC_ROOT}/examples/program_output_example.rb"
      )
      test.start
      test.assert_screen

      test.send_keys('next', :Enter)
      test.send_keys('next', :Enter)
      test.send_keys('jard output', :Enter)
      test.assert_screen

      test.send_keys('k')
      test.assert_screen

      test.send_keys('g')
      sleep 1
      test.assert_screen

      test.send_keys('q')
      sleep 1
      test.assert_screen
    ensure
      test.stop
    end
  end
end
