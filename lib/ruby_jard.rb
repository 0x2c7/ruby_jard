# frozen_string_literal: true

require 'pry'
require 'byebug/core'
require 'byebug/attacher'
require 'forwardable'
require 'benchmark'

require 'ruby_jard/path_classifier'
require 'ruby_jard/path_filter'
require 'ruby_jard/control_flow'
require 'ruby_jard/config'
require 'ruby_jard/keys'
require 'ruby_jard/key_binding'
require 'ruby_jard/key_bindings'
require 'ruby_jard/repl_proxy'
require 'ruby_jard/repl_processor'
require 'ruby_jard/screen_manager'

require 'ruby_jard/frame'
require 'ruby_jard/thread_info'
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

  def self.benchmark(name)
    @benchmark_depth ||= 0
    @benchmark_depth += 1
    return_value = nil
    time = Benchmark.realtime { return_value = yield }
    debug("#{' ' * @benchmark_depth}Benchmark `#{name}`: #{time}")
    @benchmark_depth -= 1
    return_value
  end

  def self.debug(*info)
    @debug_info ||= []
    @debug_info += info
    File.open('./jard_debugs.txt', 'a') do |f|
      info.each do |line|
        f.puts line
      end
    end
  end

  def self.error(exception)
    File.open('./jard_errors.txt', 'a') do |f|
      f.puts '--- Error ---'
      f.puts exception.message
      f.puts exception.backtrace
    end
  rescue StandardError
    # Ignore
  end

  def self.debug_info
    @debug_info ||= []
  end

  def self.clear_debug
    @debug_info = []
  end

  def self.global_key_bindings
    return @global_key_bindings if defined?(@global_key_bindings)

    @global_key_bindings = RubyJard::KeyBindings.new
    RubyJard::Keys::DEFAULT_KEY_BINDINGS.each do |sequence, action|
      @global_key_bindings.push(sequence, action)
    end
    @global_key_bindings
  end

  def self.config
    @config ||= RubyJard::Config.smart_load
  end
end

##
# Monkey-patch Kernel module to allow putting jard command anywhere.
module Kernel
  def jard
    RubyJard::Session.instance.attach
  end

  if RubyJard.config.alias_to_debugger
    alias_method :debugger, :jard
  end
end
