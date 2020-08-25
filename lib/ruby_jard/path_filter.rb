# frozen_string_literal: true

module RubyJard
  ##
  # Check whether a particular path should be passed when debugging.
  # Filtering is based on path classification (from PathClassifier),
  # program's current filter mode, and filter included, excluded.
  class PathFilter
    FILTERS = [
      FILTER_EVERYTHING = :everything,
      FILTER_GEMS = :gems,
      FILTER_APPLICATION = :application,
      FILTER_SOURCE_TREE = :source_tree
    ].freeze
    def initialize(config: nil, classifier: nil)
      @config = config || RubyJard.config
      @path_classifier = classifier || RubyJard::PathClassifier.new
    end

    def match?(path)
      case @config.filter
      when FILTER_EVERYTHING
        match_everything?(path)
      when FILTER_GEMS
        match_gems?(path)
      when FILTER_APPLICATION
        match_application?(path)
      when FILTER_SOURCE_TREE
        match_source_tree?(path)
      end
    end

    private

    def match_everything?(path)
      return true if @config.filter_excluded.empty?

      # Always return true, unless path is explicitly mentioned in excluded list
      !match_excluded?(path)
    end

    def match_gems?(path)
      type, *info = @path_classifier.classify(path)

      case type
      when RubyJard::PathClassifier::TYPE_SOURCE_TREE, RubyJard::PathClassifier::TYPE_UNKNOWN
        !match_excluded?(path)
      when RubyJard::PathClassifier::TYPE_GEM
        !match_excluded?(info[0], expand_path: false) && !match_excluded?(path)
      when RubyJard::PathClassifier::TYPE_STDLIB
        match_included?(info[0], expand_path: false) || match_included?(path)
      when RubyJard::PathClassifier::TYPE_RUBY_SCRIPT, RubyJard::PathClassifier::TYPE_EVALUATION
        true
      when RubyJard::PathClassifier::TYPE_INTERNAL
        false
      end
    end

    def match_application?(path)
      type, *info = @path_classifier.classify(path)

      case type
      when RubyJard::PathClassifier::TYPE_SOURCE_TREE, RubyJard::PathClassifier::TYPE_UNKNOWN
        !match_excluded?(path)
      when RubyJard::PathClassifier::TYPE_GEM, RubyJard::PathClassifier::TYPE_STDLIB
        match_included?(info[0], expand_path: false) || match_included?(path)
      when RubyJard::PathClassifier::TYPE_RUBY_SCRIPT, RubyJard::PathClassifier::TYPE_EVALUATION
        true
      when RubyJard::PathClassifier::TYPE_INTERNAL
        false
      end
    end

    def match_source_tree?(path)
      type, *info = @path_classifier.classify(path)

      case type
      when RubyJard::PathClassifier::TYPE_SOURCE_TREE
        !match_excluded?(path)
      when RubyJard::PathClassifier::TYPE_UNKNOWN
        match_included?(path)
      when RubyJard::PathClassifier::TYPE_GEM, RubyJard::PathClassifier::TYPE_STDLIB
        match_included?(info[0], expand_path: false) || match_included?(path)
      when RubyJard::PathClassifier::TYPE_RUBY_SCRIPT, RubyJard::PathClassifier::TYPE_EVALUATION
        true
      when RubyJard::PathClassifier::TYPE_INTERNAL
        false
      end
    end

    def match_excluded?(path, expand_path: true)
      @config.filter_excluded.any? do |excluded|
        if expand_path
          File.fnmatch(File.expand_path(excluded), path)
        else
          File.fnmatch(excluded, path)
        end
      end
    end

    def match_included?(path, expand_path: true)
      @config.filter_included.any? do |included|
        if expand_path
          File.fnmatch(File.expand_path(included), path)
        else
          File.fnmatch(included, path)
        end
      end
    end
  end
end
