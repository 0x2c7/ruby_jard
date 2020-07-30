# frozen_string_literal: true

require 'bundler/setup'
require 'ruby_jard'
require_relative './helpers/shared_command_with_times_spec'

##
# Config to test pry-related commands. Copy from pry and pry-byebug test base
Pry.config.color = false
Pry.config.pager = false
Pry.config.correct_indent = false

def redirect_pry_io(new_in, new_out = StringIO.new)
  old_in = Pry.input
  old_out = Pry.output
  Pry.input = new_in
  Pry.output = new_out
  begin
    yield
  ensure
    Pry.input = old_in
    Pry.output = old_out
  end
end

class InputTester
  def initialize(*actions)
    @actions = actions
  end

  def add(*actions)
    @actions += actions
  end

  def readline(*)
    @actions.shift
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
