# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

if Gem.path.all? { |path| Dir[File.join(path, 'gems/jard_merge_sort*')].empty? }
  puts '[HACK] Install jard_merge_sort'
  puts `gem install ./spec/examples/jard_merge_sort/jard_merge_sort-0.1.0.gem`
end

gem 'byebug', '~> 12.0'
gem 'jard_merge_sort', require: false
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.0'
gem 'rubocop', '~> 1.91.0'
gem 'rubocop-rspec', '~> 3.10.0', require: false
gem 'tty-markdown', '~>0.7.0'

group :test do
  gem 'activerecord'
  # The irb placement specs pass --nobanner, which irb 1.18 introduced along
  # with its startup banner.
  gem 'irb', '>= 1.18'
  gem 'parallel_tests'
  gem 'reline', require: false
  gem 'rspec-retry'
  # activesupport pulls in the securerandom gem over the default gem. The
  # scenario_3 fixture steps through its internals, so keep them stable.
  gem 'securerandom', '~> 0.4.0'
  gem 'sqlite3'
end
