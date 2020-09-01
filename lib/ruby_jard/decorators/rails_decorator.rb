# frozen_string_literal: true

module RubyJard
  module Decorators
    ##
    # A collection of rails-specific decorators.
    # Why?
    # Because Rails is magic, and it is like stepping on a minefield. Rails objects
    # can trigger side-effects (like calling database queries, or even API queries).
    # And from the end-user perspective, Rails' internal variables are useless. They
    # care more about database attributes, which requires some extra steps to display
    # if I don't want to use `#inspect`.
    class RailsDecorator
      ##
      # Individual Active Record object is trivial. The object is a mapping from a DB
      # entity to Ruby object. It is always in the memory.
      class ActiveRecordBaseDecorator
        def initialize(generic_decorator)
          @generic_decorator = generic_decorator
          @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(generic_decorator)
        end

        def match?(variable)
          return false unless defined?(ActiveRecord::Base)

          RubyJard::Reflection.call_is_a?(variable, ActiveRecord::Base)
        end

        def decorate_singleline(variable, line_limit:, depth: 0)
          label = RubyJard::Span.new(
            content: RubyJard::Reflection.call_to_s(variable).chomp!('>'),
            margin_right: 1, styles: :text_primary
          )
          spans = [label]
          spans += @attributes_decorator.inline_pairs(
            variable.attributes.each_with_index,
            total: variable.attributes.length, line_limit: line_limit - label.content_length - 2,
            process_key: false, depth: depth + 1
          )
          spans << RubyJard::Span.new(content: '>', styles: :text_primary)
        end

        def decorate_multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
          singleline = decorate_singleline(variable, line_limit: first_line_limit)

          if singleline.map(&:content_length).sum < line_limit
            [singleline]
          else
            spans = [RubyJard::Span.new(content: RubyJard::Reflection.call_to_s(variable), styles: :text_primary)]

            item_count = 0
            variable.attributes.each_with_index do |(key, value), index|
              spans << @attributes_decorator.pair(
                key, value, line_limit: line_limit, process_key: false, depth: depth + 1
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

      ##
      # When creating an active record relation, Rails won't trigger any SQL query, until
      # to_ary events. It is required to check for records loaded before recursively display
      # its children. Hint if the relation is not loaded yet.
      class ActiveRecordRelationDecorator
        def initialize(generic_decorator)
          @generic_decorator = generic_decorator
          @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(generic_decorator)
        end

        def match?(variable)
          return false unless defined?(ActiveRecord::Relation)

          RubyJard::Reflection.call_class(variable) < ActiveRecord::Relation
        rescue StandardError
          false
        end

        def decorate_singleline(variable, line_limit:, depth: 0)
          if variable.respond_to?(:loaded?) && variable.loaded?
            spans = []
            label = RubyJard::Span.new(
              content: RubyJard::Reflection.call_to_s(variable).chomp('>'), styles: :text_primary
            )
            spans << label
            spans += @attributes_decorator.inline_values(
              variable.each_with_index,
              total: variable.length, line_limit: line_limit - label.content_length - 2,
              depth: depth + 1
            )
            spans << RubyJard::Span.new(content: '>', styles: :text_primary)

            spans
          else
            relation_summary(variable, line_limit)
          end
        end

        def decorate_multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
          singleline = decorate_singleline(variable, line_limit: first_line_limit)
          if singleline.map(&:content_length).sum < line_limit
            [singleline]
          elsif !variable.respond_to?(:loaded?) || !variable.loaded?
            [relation_summary(variable, first_line_limit)]
          else
            spans = [[RubyJard::Span.new(content: RubyJard::Reflection.call_to_s(variable), styles: :text_primary)]]

            item_count = 0
            variable.each_with_index do |value, index|
              spans << @attributes_decorator.value(value, line_limit: line_limit, depth: depth + 1)

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

        private

        def relation_summary(variable, line_limit)
          overview = RubyJard::Reflection.call_to_s(variable).chomp('>')
          width = overview.length + 1 + 12
          spans = [RubyJard::Span.new(content: overview, styles: :text_primary)]
          if RubyJard::Reflection.call_respond_to?(variable, :to_sql) && width < line_limit
            detail = variable.to_sql
            detail = detail[0..line_limit - width - 2] + '…' if width + detail.length < line_limit
            spans << RubyJard::Span.new(content: detail, styles: :text_dim, margin_left: 1)
          end
          spans << RubyJard::Span.new(content: '>', styles: :text_primary)
          spans << RubyJard::Span.new(content: '(not loaded)', margin_left: 1, styles: :text_dim)
          spans
        end
      end

      def initialize(generic_decorator)
        @generic_decorator = generic_decorator
        @sub_decorators = [
          @active_record_base_decorator = ActiveRecordBaseDecorator.new(generic_decorator),
          @active_record_relation_decorator = ActiveRecordRelationDecorator.new(generic_decorator)
        ]
      end

      def match?(variable)
        @sub_decorators.any? { |sub_decorator| sub_decorator.match?(variable) }
      rescue StandardError
        false
      end

      def decorate_singleline(variable, line_limit:, depth: 0)
        @sub_decorators.each do |sub_decorator|
          next unless sub_decorator.match?(variable)

          return sub_decorator.decorate_singleline(
            variable, line_limit: line_limit, depth: depth
          )
        end

        nil
      end

      def decorate_multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        @sub_decorators.each do |sub_decorator|
          next unless sub_decorator.match?(variable)

          return sub_decorator.decorate_multiline(
            variable,
            first_line_limit: first_line_limit,
            lines: lines,
            line_limit: line_limit,
            depth: depth
          )
        end

        nil
      end
    end
  end
end
