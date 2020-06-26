require_relative 'lib/ruby_jard/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby_jard"
  spec.version       = RubyJard::VERSION
  spec.authors       = ["Minh Nguyen"]
  spec.email         = ["nguyenquangminh0711@gmail.com"]

  spec.summary       = %q{Just Another Ruby Debugger}
  spec.description   = %q{Ruby Jard provides an unified experience debugging Ruby source code in different platforms and editors.}
  spec.homepage      = "https://github.com/nguyenquangminh0711/ruby_jard"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nguyenquangminh0711/ruby_jard"
  spec.metadata["changelog_uri"] = "https://github.com/nguyenquangminh0711/ruby_jard"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'tty-screen', '>= 0.8.0'
  spec.add_runtime_dependency 'tty-cursor', '>= 0.7.1'
  spec.add_runtime_dependency 'tty-box', '>= 0.5.0'

  spec.add_runtime_dependency 'pry', '>= 0.13.0'
  spec.add_runtime_dependency 'byebug', '>= 11.1.0'
end
