require 'ruby_jard'
require 'erb'

lineno = __LINE__
view = <<-VIEW
  <h1><%= jard %><%= jard %> <%= jard %></h1>
  <h1><% a = 1 %></h1>
VIEW

erb = ERB.new(view)
erb.filename = __FILE__
erb.lineno = lineno
erb.result
