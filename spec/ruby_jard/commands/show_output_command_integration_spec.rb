# frozen_string_literal: true

RSpec.describe 'RubyJard::Commands::ShowOutputCommand Integration tests' do
  let(:work_dir) { File.join(RSPEC_ROOT, '/ruby_jard/commands') }

  context 'when there is no output yet' do
    it 'displays empty pager' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/program_output_example.rb")
      test.start
      expect(test.screen_content).to match_repl(<<~SCREEN)
        jard >>
      SCREEN
      test.send_keys('show-output', :Enter)
      expect(test.screen_content).to match_repl(<<~SCREEN)
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        (END)
      SCREEN
    ensure
      test.stop
    end
  end

  context 'when there the output fits into the screen' do
    it 'displays full pager stopping at the end of file' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/program_output_example.rb")
      test.start
      expect(test.screen_content).to match_repl(<<~SCREEN)
        jard >>
      SCREEN
      test.send_keys('next', :Enter)
      test.send_keys('show-output', :Enter)
      expect(test.screen_content).to match_repl(<<~SCREEN)
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        ?
        10 | 0: abcdef
        10 | 1: abcdef
        10 | 2: abcdef
        10 | 3: abcdef
        10 | 4: abcdef
        10 | 5: abcdef
        10 | 6: abcdef
        10 | 7: abcdef
        10 | 8: abcdef
        10 | 9: abcdef
        (END)
      SCREEN
    ensure
      test.stop
    end
  end

  context 'when there the output overflow the screen' do
    it 'displays interactive pager fit into the screen' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/program_output_example.rb")
      test.start
      expect(test.screen_content).to match_repl(<<~SCREEN)
        jard >>
      SCREEN
      test.send_keys('next', :Enter)
      test.send_keys('next', :Enter)
      test.send_keys('show-output', :Enter)
      expect(test.screen_content).to match_repl(<<~SCREEN)
        100 | 77: xyz
        100 | 78: xyz
        100 | 79: xyz
        100 | 80: xyz
        100 | 81: xyz
        100 | 82: xyz
        100 | 83: xyz
        100 | 84: xyz
        100 | 85: xyz
        100 | 86: xyz
        100 | 87: xyz
        100 | 88: xyz
        100 | 89: xyz
        100 | 90: xyz
        100 | 91: xyz
        100 | 92: xyz
        100 | 93: xyz
        100 | 94: xyz
        100 | 95: xyz
        100 | 96: xyz
        100 | 97: xyz
        100 | 98: xyz
        100 | 99: xyz
        (END)
      SCREEN

      test.send_keys('k')
      expect(test.screen_content).to match_repl(<<~SCREEN)
        100 | 76: xyz
        100 | 77: xyz
        100 | 78: xyz
        100 | 79: xyz
        100 | 80: xyz
        100 | 81: xyz
        100 | 82: xyz
        100 | 83: xyz
        100 | 84: xyz
        100 | 85: xyz
        100 | 86: xyz
        100 | 87: xyz
        100 | 88: xyz
        100 | 89: xyz
        100 | 90: xyz
        100 | 91: xyz
        100 | 92: xyz
        100 | 93: xyz
        100 | 94: xyz
        100 | 95: xyz
        100 | 96: xyz
        100 | 97: xyz
        100 | 98: xyz
        :
      SCREEN

      test.send_keys('g')
      sleep 1
      expect(test.screen_content).to match_repl(<<~SCREEN)
        10 | 0: abcdef
        10 | 1: abcdef
        10 | 2: abcdef
        10 | 3: abcdef
        10 | 4: abcdef
        10 | 5: abcdef
        10 | 6: abcdef
        10 | 7: abcdef
        10 | 8: abcdef
        10 | 9: abcdef
        100 | 0: xyz
        100 | 1: xyz
        100 | 2: xyz
        100 | 3: xyz
        100 | 4: xyz
        100 | 5: xyz
        100 | 6: xyz
        100 | 7: xyz
        100 | 8: xyz
        100 | 9: xyz
        100 | 10: xyz
        100 | 11: xyz
        100 | 12: xyz
        :
      SCREEN

      test.send_keys('q')
      sleep 1
      expect(test.screen_content).to match_repl(<<~SCREEN)
        10 | 1: abcdef
        10 | 2: abcdef
        10 | 3: abcdef
        10 | 4: abcdef
        10 | 5: abcdef
        10 | 6: abcdef
        10 | 7: abcdef
        10 | 8: abcdef
        10 | 9: abcdef
        100 | 0: xyz
        100 | 1: xyz
        100 | 2: xyz
        100 | 3: xyz
        100 | 4: xyz
        100 | 5: xyz
        100 | 6: xyz
        100 | 7: xyz
        100 | 8: xyz
        100 | 9: xyz
        100 | 10: xyz
        100 | 11: xyz
        100 | 12: xyz
        jard >> Tips: You can use `list` command to show back debugger screens
        jard >>
      SCREEN
    ensure
      test.stop
    end
  end
end
