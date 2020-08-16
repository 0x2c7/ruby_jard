# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/retry'
require 'ruby_jard'

RSPEC_ROOT = File.dirname __FILE__

def require_relative_folder(pattern)
  pattern = File.expand_path(File.join(File.dirname(__FILE__), pattern))
  Dir[pattern].sort.each do |file|
    require file
  end
end

require_relative_folder('./helpers/**/*')
require_relative_folder('./shared/**/*')

RSpec.configure do |config|
  config.verbose_retry = true
  config.display_try_failure_messages = true

  config.around :each, :integration do |ex|
    ex.run_with_retry retry: 3
  end

  config.after :suite do
    JardIntegrationTest.tests.each do |test|
      test.stop
      puts "Someone forgot to stop integration test at #{test.source}"
    end
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
