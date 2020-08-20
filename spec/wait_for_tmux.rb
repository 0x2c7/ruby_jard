# frozen_string_literal: true

require 'English'
attempt = 10

loop do
  exit 1 if attempt <= 0
  attempt -= 1
  puts "Wait for tmux. Attempt #{attempt}"
  test_result = `tmux info 2>&1`
  if test_result =~ /no server/
    sleep 1
  else
    exit 0
  end
end
