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
      EVALUATION_SIGNATURES = ['(eval)', '-e'].freeze
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

      attr_reader :path, :lineno, :path_label

      def initialize(path, lineno)
        @path = path.to_s
        @lineno = lineno
        @path_label = ''
        @type = TYPE_UNKNOWN

        decorate
      end

      def decorate
        @path_label = @path

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
          gem_name = splitted_path.first
          match = GEM_PATTERN.match(gem_name)
          if match
            gem_name = match[1]
            gem_version = match[2]
            @path_label = "<#{gem_name} #{gem_version}>"
          else
            @path_label = "<#{gem_name}>"
          end

          break
        end
      end

      def try_classify_internal_prelude
        # https://github.com/ruby/ruby/blob/master/template/prelude.c.tmpl#L18
        return unless @path =~ INTERNAL_PATTERN

        @type = TYPE_INTERNAL
        @path_label = @path
      end

      def try_classify_stdlib
        lib_dir = RbConfig::CONFIG['rubylibdir'].to_s.strip

        return if lib_dir.empty?
        return unless @path.start_with?(lib_dir)

        @type = TYPE_STDLIB

        lib_name =
          @path[lib_dir.length..-1]
          .split('/')
          .reject(&:empty?)
          .first

        match = STDLIB_PATTERN.match(lib_name)
        lib_name = match[1] if match

        @path_label = "<stdlib:#{lib_name}>"
      rescue NameError
        # RbConfig is not available
      end

      def try_classify_evaluation
        return unless EVALUATION_SIGNATURES.include?(@path)

        @type = TYPE_EVALUATION
        @path_label = @path
      end

      def try_classify_source_tree
        return unless @path.start_with?(Dir.pwd)

        @type = TYPE_SOURCE_TREE
        @path_label = @path[Dir.pwd.length..-1]
        @path_label = @path_label[1..-1] if @path_label.start_with?('/')
      end

      def compact_with_relative_path
        relative_path = Pathname.new(@path).relative_path_from(Pathname.pwd).to_s
        if relative_path.length < @path.length
          @path_label = relative_path
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
