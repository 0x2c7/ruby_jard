# frozen_string_literal: true

windows =
  `tmux list-sessions`
  .split
  .select { |w| w.start_with?('TestJard') }
  .map { |w| w.split(':').first }

puts "Detect #{windows.length} sessions"
windows.each do |window|
  puts "Killing #{window}"
  puts `tmux kill-session -t #{window}`
end
