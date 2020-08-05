# frozen_string_literal: true

require 'bundler/setup'
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
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
