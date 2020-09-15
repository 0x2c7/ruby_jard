# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/retry'
require 'ruby_jard'
require 'tempfile'

# Prepare for unit tests. All integration tests run in separate processes with pure ruby command.
# Therefore, they stay intact, will need `jard` magic method call to attach
RubyJard::Session.instance.start

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
      puts "Someone forgot to stop integration test at #{test.source}"
      begin
        test.stop
      rescue StandardError => e
        puts "Fail to stop test. Error: #{e}"
      end
    end
  end

  config.retry_callback = proc do
    if ENV['CI']
      puts '==== Tmux ===='
      puts 'Restart Tmux...'
      begin
        puts `tmux kill-server`
      rescue StandardError
        # Ignore
      end

      begin
        puts `kill -9 $(ps aux | grep tmux | awk '{print $2}')`
      rescue StandardError
        # Ignore
      end
      sleep 3
      `tmux start-server`
      `tmux new-session -t dummy -d`
      `ruby spec/wait_for_tmux.rb`
      puts '==== End Tmux ===='
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
