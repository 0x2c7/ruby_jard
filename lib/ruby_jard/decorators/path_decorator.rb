# frozen_string_literal: true

require 'pathname'
require 'rbconfig'

module RubyJard
  module Decorators
    ##
    # Simplify and generate labels to indicate the location of a path.
    # The return value is an array of two elements. The first one is overview,
    # the second is detailed path location.
    class PathDecorator
      def initialize(path_classifier: nil)
        @path_classifier = path_classifier || RubyJard::PathClassifier.new
      end

      def decorate(path, lineno = nil)
        return ['at ???', 'at ???'] if path.nil?

        type, *info = @path_classifier.classify(path)

        lineno = ":#{lineno}" unless lineno.nil?

        case type
        when RubyJard::PathClassifier::TYPE_SOURCE_TREE
          path = File.expand_path(path)
          decorate_source_tree(path, lineno)
        when RubyJard::PathClassifier::TYPE_GEM
          decorate_gem(path, lineno, info)
        when RubyJard::PathClassifier::TYPE_STDLIB
          decorate_stdlib(path, lineno, info)
        when RubyJard::PathClassifier::TYPE_INTERNAL
          ["in #{path}", path]
        when RubyJard::PathClassifier::TYPE_EVALUATION
          ["at #{path}#{lineno}", "#{path}#{lineno}"]
        when RubyJard::PathClassifier::TYPE_RUBY_SCRIPT
          ["at (-e ruby script)#{lineno}", "(-e ruby script)#{lineno}"]
        else
          path = compact_with_relative_path(path)
          ["at #{path}#{lineno}", "#{path}#{lineno}"]
        end
      end

      private

      def decorate_source_tree(path, lineno)
        path = path[Dir.pwd.length..-1]
        path = path[1..-1] if path.start_with?('/')
        path = "#{path}#{lineno}"
        ["at #{path}", path]
      end

      def decorate_gem(_path, lineno, info)
        gem_name, gem_version, relative_path = info
        overview =
          if gem_version.nil?
            "<#{gem_name}>"
          else
            "<#{gem_name} #{gem_version}>"
          end
        detail = "<#{gem_name}:#{relative_path}#{lineno}>"
        ["in #{overview}", detail]
      end

      def decorate_stdlib(_path, lineno, info)
        lib_name, relative_path = info

        ["in <stdlib:#{lib_name}>", "<stdlib:#{relative_path}#{lineno}>"]
      end

      def compact_with_relative_path(path)
        relative_path = Pathname.new(path).relative_path_from(Pathname.pwd).to_s
        if relative_path.length < path.length
          relative_path
        else
          path
        end
      rescue ArgumentError
        # Fail to get relative path, ignore
        path
      end
    end
  end
end
