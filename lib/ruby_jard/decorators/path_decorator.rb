# frozen_string_literal: true

require 'pathname'
require 'rbconfig'

module RubyJard
  module Decorators
    ##
    # Simplify and generate labels to indicate the location of a path.
    # If it's from gem, strip Gem paths, or Bundler paths to expose relative
    # location of the file.
    # If it's from the current working dir, strip the working dir.
    class PathDecorator
      EVALUATION_SIGNATURE = '(eval)'
      RUBY_SCRIPT_SIGNATURE = '-e'
      STDLIB_PATTERN = /(.*)\.rb$/.freeze
      INTERNAL_PATTERN = /<internal:[^>]+>/.freeze
      GEM_PATTERN = /(.*)-(\d+\.\d+[.\d]*[.\d]*[-.\w]*)/i.freeze
      PATH_TYPES = [
        TYPE_UNKNOWN = :unknown,
        TYPE_SOURCE_TREE = :source_tree,
        TYPE_GEM = :gem,
        TYPE_STDLIB = :lib,
        TYPE_INTERNAL = :internal,
        TYPE_EVALUATION = :evaluation
      ].freeze

      attr_reader :path, :module_label, :module_path

      def initialize(path, lineno)
        @path = path.to_s
        @lineno = lineno
        @module_label = ''
        @module_path = ''
        @type = TYPE_UNKNOWN

        decorate
      end

      def decorate
        @module_label = @path
        @module_path = @path

        try_classify_gem
        return if gem?

        try_classify_stdlib
        return if stdlib?

        try_classify_internal_prelude
        return if internal?

        try_classify_evaluation
        return if evaluation?

        try_classify_source_tree
        return if source_tree?

        compact_with_relative_path
      end

      def unknown?
        @type == TYPE_UNKNOWN
      end

      def gem?
        @type == TYPE_GEM
      end

      def source_tree?
        @type == TYPE_SOURCE_TREE
      end

      def stdlib?
        @type == TYPE_STDLIB
      end

      def internal?
        @type == TYPE_INTERNAL
      end

      def evaluation?
        @type == TYPE_EVALUATION
      end

      private

      def try_classify_gem
        gem_paths.each do |gem_path|
          next unless @path.start_with?(gem_path)

          @type = TYPE_GEM
          splitted_path =
            @path[gem_path.length..-1]
            .split('/')
            .reject(&:empty?)
          gem_name = splitted_path.shift
          match = GEM_PATTERN.match(gem_name)
          if match
            gem_name = match[1]
            gem_version = match[2]
            @module_label = "<#{gem_name} #{gem_version}>"
          else
            @module_label = "<#{gem_name}>"
          end
          @module_path = "<#{gem_name}:#{splitted_path.join('/')}:#{@lineno}>"

          break
        end
      end

      def try_classify_internal_prelude
        # https://github.com/ruby/ruby/blob/master/template/prelude.c.tmpl#L18
        return unless @path =~ INTERNAL_PATTERN

        @type = TYPE_INTERNAL
        @module_label = @path
        @module_path = @path
      end

      def try_classify_stdlib
        lib_dir = RbConfig::CONFIG['rubylibdir'].to_s.strip

        return if lib_dir.empty?
        return unless @path.start_with?(lib_dir)

        @type = TYPE_STDLIB

        splitted_path =
          @path[lib_dir.length..-1]
          .split('/')
          .reject(&:empty?)
        lib_name = splitted_path.first
        match = STDLIB_PATTERN.match(lib_name)
        lib_name = match[1] if match

        @module_label = "<stdlib:#{lib_name}>"
        @module_path = "<stdlib:#{splitted_path.join('/')}:#{@lineno}>"
      rescue NameError
        # RbConfig is not available
      end

      def try_classify_evaluation
        case @path
        when EVALUATION_SIGNATURE
          @type = TYPE_EVALUATION
          @module_label = EVALUATION_SIGNATURE
          @module_path = EVALUATION_SIGNATURE
        when RUBY_SCRIPT_SIGNATURE
          @type = TYPE_EVALUATION
          @module_label = '(-e ruby script)'
          @module_path = '(-e ruby script)'
        end
      end

      def try_classify_source_tree
        return unless @path.start_with?(Dir.pwd)

        @type = TYPE_SOURCE_TREE
        @module_label = @path[Dir.pwd.length..-1]
        @module_label = @module_label[1..-1] if @module_label.start_with?('/')
        @module_path = "#{@module_label}:#{@lineno}"
      end

      def compact_with_relative_path
        relative_path = Pathname.new(@path).relative_path_from(Pathname.pwd).to_s
        if relative_path.length < @path.length
          @module_label = relative_path
          @module_path = "#{relative_path}:#{@lineno}"
        end
      rescue ArgumentError
        # Fail to get relative path, ignore
      end

      def gem_paths
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
end
