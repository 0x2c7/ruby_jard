# frozen_string_literal: true

module RubyJard
  class RailsDecorator
    class ActiveRecordBaseDecorator
      def initialize(general_decorator)
        @general_decorator = general_decorator
        @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(general_decorator)
      end

      def match?(variable)
        return false unless defined?(ActiveRecord::Base)

        variable.is_a?(ActiveRecord::Base)
      end

      def decorate_singleline(variable, line_limit:)
        label = RubyJard::Span.new(content: variable.to_s.chomp!('>'), margin_right: 1, styles: :text_secondary)
        spans = [label]
        spans += @attributes_decorator.inline_pairs(
          variable.attributes.each_with_index,
          total: variable.attributes.length, line_limit: line_limit - label.content_length - 2, process_key: false
        )
        spans << RubyJard::Span.new(content: '>', styles: :text_secondary)
      end

      def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
        singleline = decorate_singleline(variable, line_limit: first_line_limit)

        if singleline.map(&:content_length).sum < line_limit
          [singleline]
        else
          spans = [RubyJard::Span.new(content: variable.to_s, styles: :text_secondary)]

          item_count = 0
          variable.attributes.each_with_index do |(key, value), index|
            spans << @attributes_decorator.pair(
              key, value, line_limit: line_limit, process_key: false
            )
            item_count += 1
            break if index >= lines - 2
          end
          if variable.attributes.length > item_count
            spans << [RubyJard::Span.new(
              content: "▸ #{variable.attributes.length - item_count} more...",
              margin_left: 2, styles: :text_dim
            )]
          end
          spans
        end
      end
    end

    class ActiveRecordRelationDecorator
      def initialize(general_decorator)
        @general_decorator = general_decorator
        @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(general_decorator)
      end

      def match?(variable)
        return false unless defined?(ActiveRecord::Relation)

        variable.class < ActiveRecord::Relation
      rescue StandardError
        false
      end

      def decorate_singleline(variable, line_limit:)
        if variable.respond_to?(:loaded?) && variable.loaded?
          spans = []
          label = RubyJard::Span.new(content: variable.to_s.chomp('>'), styles: :text_secondary)
          spans << label
          spans += @attributes_decorator.inline_values(
            variable.each_with_index, total: variable.length, line_limit: line_limit - label.content_length - 2
          )
          spans << RubyJard::Span.new(content: '>', styles: :text_secondary)

          spans
        else
          [
            RubyJard::Span.new(content: variable.to_s, styles: :text_secondary),
            RubyJard::Span.new(content: '(not loaded)', margin_left: 1, styles: :text_dim)
          ]
        end
      end

      def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
        singleline = decorate_singleline(variable, line_limit: first_line_limit)
        if singleline.map(&:content_length).sum < line_limit
          [singleline]
        elsif !variable.respond_to?(:loaded?) || !variable.loaded?
          [
            [
              RubyJard::Span.new(content: variable.to_s, styles: :text_secondary),
              RubyJard::Span.new(content: '(not loaded)', margin_left: 1, styles: :text_dim)
            ]
          ]
        else
          spans = [[RubyJard::Span.new(content: variable.to_s, styles: :text_secondary)]]

          item_count = 0
          variable.each_with_index do |value, index|
            spans << @attributes_decorator.value(value, line_limit: line_limit)

            item_count += 1
            break if index >= lines - 2
          end
          if variable.length > item_count
            spans << [RubyJard::Span.new(
              content: "▸ #{variable.length - item_count} more...",
              margin_left: 2, styles: :text_dim
            )]
          end
          spans
        end
      end
    end

    def initialize(general_decorator)
      @general_decorator = general_decorator
      @sub_decorators = [
        @active_record_base_decorator = ActiveRecordBaseDecorator.new(general_decorator),
        @active_record_relation_decorator = ActiveRecordRelationDecorator.new(general_decorator)
      ]
    end

    def match?(variable)
      @sub_decorators.any? { |sub_decorator| sub_decorator.match?(variable) }
    rescue StandardError
      false
    end

    def decorate_singleline(variable, line_limit:)
      @sub_decorators.each do |sub_decorator|
        next unless sub_decorator.match?(variable)

        return sub_decorator.decorate_singleline(
          variable, line_limit: line_limit
        )
      end

      nil
    end

    def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
      @sub_decorators.each do |sub_decorator|
        next unless sub_decorator.match?(variable)

        return sub_decorator.decorate_multiline(
          variable,
          first_line_limit: first_line_limit,
          lines: lines,
          line_limit: line_limit
        )
      end

      nil
    end
  end
end
