# frozen_string_literal: true

RSpec.describe 'RubyJard::Commands::ColorSchemeCommand Integration tests' do
  let(:work_dir) { File.join(RSPEC_ROOT, '/ruby_jard/commands') }

  context 'when list color schemes' do
    it 'displays list of schemes' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/test1_example.rb")
      test.start
      test.send_keys('color-scheme', 'Space', '-l', 'Enter')
      expect(test.screen_content).to match_repl(<<~SCREEN)
        jard >> color-scheme -l
        256
        deep-space
        gruvbox
        jard >>
      SCREEN
    ensure
      test.stop
    end
  end

  context 'when switching to new scheme' do
    it 'displays no error' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/test1_example.rb")
      test.start
      test.send_keys('color-scheme', 'Space', '256', 'Enter')
      expect(test.screen_content).to match_repl(<<~SCREEN)
        jard >> 
      SCREEN
    ensure
      test.stop
    end
  end

  context 'when switching to not-found scheme' do
    it 'displays error' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/test1_example.rb")
      test.start
      test.send_keys('color-scheme', 'Space', 'NotExistedScheme', 'Enter')
      expect(test.screen_content).to match_repl(<<~SCREEN)
        jard >> color-scheme NotExistedScheme
        Error: Color scheme `NotExistedScheme` not found. Please use `color-scheme -l` to list all color schemes.
        jard >>
      SCREEN
    ensure
      test.stop
    end
  end
end
