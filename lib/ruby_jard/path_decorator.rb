# frozen_string_literal: true

module RubyJard
  module Decorators
    class PathDecorator
      PATH_TYPES = [
        TYPE_UNKNOWN = :unknown,
        TYPE_PWD = :pwd,
        TYPE_GEM = :gem
      ].freeze

      attr_reader :path, :lineno, :gem

      def initialize(location)
        @gem = nil
        @path = location.path
        @lineno = location.lineno
        @type = TYPE_UNKNOWN

        process_path
      end

      def process_path
        if path.start_with?(Dir.pwd)
          @type = TYPE_PWD
          @path = @path[Dir.pwd.length..-1]
          @path = @path[1..-1] if @path.start_with?('/')
        else
          gem_paths.each do |gem_path|
            next unless path.start_with?(gem_path)

            @type = TYPE_GEM
            stripped_path = @path[gem_path.length..-1]
            stripped_path = stripped_path[1..-1] if stripped_path.start_with?('/')
            @gem = stripped_path.split('/').first
            break
          end
        end
      end

      def gem?
        @type == TYPE_GEM
      end

      private

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
