require 'pry'
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
