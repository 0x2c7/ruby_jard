# frozen_string_literal: true

require 'ruby_jard'

jard
puts "What's your name?"
name = STDIN.gets.strip

puts 'How old are your?'
age = STDIN.gets.strip.to_i

jard
puts "Hi, #{name} (#{age})"

jard
puts 'Nice to meet you'

warn 'Error! Failed to continue'
jard
puts 'Exiting'
