# frozen_string_literal: true

require 'ruby_jard'

class Proxy < BasicObject
  def initialize(core, source)
    @core = core
    @source = source
  end

  def method
    "#{@source}:#{@core[:method]}"
  end

  def uri
    "#{@source}:#{@core[:uri]}"
  end
end

proxy = Proxy.new({method: 'GET', uri: 'http://google.com'}, 'server')
jard
method_str = proxy.method
uri_str = proxy.uri
puts "#{method_str} #{uri_str}"
