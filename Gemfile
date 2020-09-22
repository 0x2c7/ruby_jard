# frozen_string_literal: true

source 'http://rubygems.org'

gemspec

if Gem.path.all? { |path| Dir[File.join(path, 'gems/jard_merge_sort*')].empty? }
  puts '[HACK] Install jard_merge_sort'
  puts `gem install ./spec/examples/jard_merge_sort/jard_merge_sort-0.1.0.gem`
end

gem 'byebug', '~> 11.1.0'
gem 'jard_merge_sort', require: false
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.0'
gem 'rubocop', '~> 0.89.1'
gem 'rubocop-rspec', '~> 1.43.1', require: false

group :test do
  gem 'activerecord'
  gem 'parallel_tests'
  gem 'rspec-retry'
  gem 'sqlite3'
end
