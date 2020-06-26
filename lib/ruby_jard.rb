require 'pry'
require 'coderay'
require 'byebug/core'
require 'byebug/attacher'
require 'tty-cursor'
require 'tty-box'
require 'tty-screen'

require 'ruby_jard/commands/continue_command'
require 'ruby_jard/commands/up_command'
require 'ruby_jard/commands/down_command'
require 'ruby_jard/commands/next_command'
require 'ruby_jard/commands/step_command'
require 'ruby_jard/commands/finish_command'

require 'ruby_jard/repl_processor'
require 'ruby_jard/server'

require 'ruby_jard/screen_manager'

require 'ruby_jard/session'
require 'ruby_jard/version'

module RubyJard
  class Error < StandardError; end

  def self.current_session
    @current_session ||= RubyJard::Session.new
  end
end

module Kernel
  def jard
    RubyJard.current_session.attach
  end
end
Pry::Prompt.add(
  :jard,
  'Custom promt for Pry'
) do |context, _nesting, pry_instance, sep|
  format(
    '%<name>s >> ',
    in_count: pry_instance.input_ring.count,
    name: :jard,
    separator: sep
  )
end
Pry.config.prompt = Pry::Prompt[:jard]
Pry.config.hooks = Pry::Hooks.new

Byebug::Setting[:autolist] = false
Byebug::Setting[:autoirb] = false
Byebug::Setting[:autopry] = false
Byebug::Context.processor = RubyJard::ReplProcessor
Byebug::Context.ignored_files = Byebug::Context.all_files + Dir.glob(
  File.join(
    File.expand_path(__dir__, '../lib'),
    '**',
    '*.rb'
  )
)
