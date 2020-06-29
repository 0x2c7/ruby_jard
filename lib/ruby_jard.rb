# frozen_string_literal: true

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
require 'ruby_jard/commands/frame_command'

require 'ruby_jard/repl_processor'
require 'ruby_jard/screen_manager'

require 'ruby_jard/session'
require 'ruby_jard/version'

##
# Jard stands for Just Another Ruby Debugger. It implements a layer of UI
# wrapping around byebug, aims to provide a unified experience when debug
# Ruby source code. Ruby Jard supports the following major features:
#
# * Default Terminal UI, in which the layout and display are responsive to
# support different screen size.
# * Highlighted source code screen.
# * Stacktrace visulization and navigation.
# * Auto explore and display variables in the current context.
# * Multi-thread exploration and debugging.
# * Minimal layout configuration.
# * Fully layout configuration with Tmux (coming soon).
# * Integrate with Vim (coming soon).
# * Integrate with Visual Studio Code (coming soon).
# * Encrypted remote debugging (coming soon).
# * Some handful debug tools and data visulization (coming soom).
#
# Ruby Jard's core is Byebug, an awesome de factor debugger for Ruby.
# Therefore, Ruby Jard supports most of Byebug's functionalities.
#
module RubyJard
  class Error < StandardError; end

  def self.current_session
    @current_session ||= RubyJard::Session.new
  end
end

##
# Monkey-patch Kernel module to allow putting jard command anywhere.
module Kernel
  def jard
    RubyJard.current_session.attach
  end
end

##
# Globally configure Byebug. Byebug doesn't allow configuration by instance.
# So, I have no choice.
# TODO: Byebug autoloaded configuration may override those values.
Byebug::Setting[:autolist] = false
Byebug::Setting[:autoirb] = false
Byebug::Setting[:autopry] = false
Byebug::Context.processor = RubyJard::ReplProcessor
# Exclude all files in Ruby Jard source code from the stacktrace.
Byebug::Context.ignored_files = Byebug::Context.all_files + Dir.glob(
  File.join(
    File.expand_path(__dir__, '../lib'),
    '**',
    '*.rb'
  )
)
