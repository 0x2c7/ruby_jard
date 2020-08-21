# frozen_string_literal: true

require_relative 'lib/jard_merge_sort/version'

Gem::Specification.new do |spec|
  spec.name          = 'jard_merge_sort'
  spec.version       = JardMergeSort::VERSION
  spec.authors       = ['Minh Nguyen']
  spec.email         = ['nguyenquangminh0711@gmail.com']

  spec.summary       = 'A dummy gem, unsed to write tests for Jard'
  spec.description   = 'A dummy gem, unsed to write tests for Jard'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['**/*.rb']
  end
  puts spec.files
  spec.require_paths = ['lib']
end
