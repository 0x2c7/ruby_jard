# frozen_string_literal: true

RSpec.describe 'Load config file from ENV', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/config') }

  context 'when config file not exist' do
    it 'raises exception' do
      test = JardIntegrationTest.new(self, work_dir, 'record.config_from_env_not_found', 'bash')
      test.start
      test.skip_screen
      test.send_keys(
        "JARD_CONFIG_FILE=/tmp/please-do-not-exist bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb",
        :Enter
      )
      test.assert_screen_include("Config file '/tmp/please-do-not-exist' does not exist")
      test.stop
    end
  end

  context 'when config file contains some error' do
    let(:config_file) { Tempfile.new('jardrc') }

    before do
      config_file.write(<<-CONFIG)
        config.enabled_screens = ['a_random_screen'
      CONFIG
      config_file.close
    end

    after do
      config_file.unlink
    end

    it 'raises exception' do
      test = JardIntegrationTest.new(self, work_dir, 'record.config_from_env_error', 'bash')
      test.start
      test.skip_screen
      test.send_keys(
        "JARD_CONFIG_FILE=#{config_file.path} bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb",
        :Enter
      )
      test.assert_screen_include('Fail to load jard configurations')
      test.stop
    end
  end

  context 'when config file exists' do
    let(:config_file) { Tempfile.new('jardrc') }

    before do
      config_file.write(<<-CONFIG)
        config.enabled_screens = ['a_random_screen']
        config.filter = :everything
      CONFIG
      config_file.close
    end

    after do
      config_file.unlink
    end

    it 'reads and loads input configuration file' do
      test = JardIntegrationTest.new(self, work_dir, 'record.config_from_env', 'bash')
      test.start
      test.skip_screen
      test.send_keys(
        "JARD_CONFIG_FILE=#{config_file.path} bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb",
        :Enter
      )
      test.send_keys('RubyJard.config.enabled_screens', :Enter)
      test.assert_screen_include('enabled_screens')
      test.stop
    end
  end
end
