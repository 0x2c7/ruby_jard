# frozen_string_literal: true

require 'pathname'
require 'rbconfig'

module RubyJard
  ##
  # Classify a particular path by its orign such as stdlib, gem, evaluation, etc.
  # Usage
  #   type, *info = PathClassifier.new.class('lib/abc')
  class PathClassifier
    GEM_PATTERN = /(.*)-(\d+\.\d+[.\d]*[.\d]*[-.\w]*)/i.freeze
    STDLIB_PATTERN = /(.*)\.rb$/.freeze
    INTERNAL_PATTERN = /<internal:[^>]+>/.freeze
    EVALUATION_SIGNATURE = '(eval)'
    RUBY_SCRIPT_SIGNATURE = '-e'

    TYPES = [
      TYPE_SOURCE_TREE = :source_tree,
      TYPE_GEM = :gem,
      TYPE_STDLIB = :stdlib,
      TYPE_INTERNAL = :internal,
      TYPE_EVALUATION = :evaluation,
      TYPE_RUBY_SCRIPT = :ruby_script,
      TYPE_UNKNOWN = :unknown
    ].freeze

    def initialize
      @gem_paths = fetch_gem_paths
    end

    def classify(path)
      return TYPE_UNKNOWN if path.nil?

      return TYPE_INTERNAL if try_classify_internal(path)

      return TYPE_EVALUATION if try_classify_evaluation(path)

      return TYPE_RUBY_SCRIPT if try_classify_ruby_script(path)

      return TYPE_SOURCE_TREE if try_classify_source_tree(path)

      matched, *info = try_classify_gem(path)
      return TYPE_GEM, *info if matched

      matched, *info = try_classify_stdlib(path)
      return TYPE_STDLIB, *info if matched

      TYPE_UNKNOWN
    end

    private

    def try_classify_gem(path)
      @gem_paths.each do |gem_path|
        next unless path.start_with?(gem_path)

        splitted_path =
          path[gem_path.length..-1]
          .split('/')
          .reject(&:empty?)
        gem_name = splitted_path.shift
        gem_version = nil

        match = GEM_PATTERN.match(gem_name)
        if match
          gem_name = match[1]
          gem_version = match[2]
        end

        return true, gem_name, gem_version, splitted_path.join('/')
      end

      false
    end

    def try_classify_internal(path)
      # https://github.com/ruby/ruby/blob/master/template/prelude.c.tmpl#L18
      path =~ INTERNAL_PATTERN
    end

    def try_classify_stdlib(path)
      lib_dir = RbConfig::CONFIG['rubylibdir'].to_s.strip

      return false if lib_dir.empty?
      return false unless path.start_with?(lib_dir)

      splitted_path =
        path[lib_dir.length..-1]
        .split('/')
        .reject(&:empty?)
      lib_name = splitted_path.first
      match = STDLIB_PATTERN.match(lib_name)
      lib_name = match[1] if match

      [true, lib_name, splitted_path.join('/')]
    rescue NameError
      # RbConfig is not available
      false
    end

    def try_classify_evaluation(path)
      path == EVALUATION_SIGNATURE
    end

    def try_classify_ruby_script(path)
      path == RUBY_SCRIPT_SIGNATURE
    end

    def try_classify_source_tree(path)
      path.start_with?(Dir.pwd)
    end

    def fetch_gem_paths
      paths = []

      if defined?(Gem)
        Gem.path.each do |gem_path|
          paths << File.join(gem_path, 'gems')
          paths << gem_path
        end
      end

      if defined?(Bundler)
        bundle_path = Bundler.bundle_path.to_s
        paths << File.join(bundle_path, 'gems')
        paths << bundle_path
      end

      paths
    end
  end
end
