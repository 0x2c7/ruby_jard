# frozen_string_literal: true

module RubyJard
  module Inspectors
    ##
    # A collection of rails-specific inspectors.
    # Why?
    # Because Rails is magic, and it is like stepping on a minefield. Rails objects
    # can trigger side-effects (like calling database queries, or even API queries).
    # And from the end-user perspective, Rails' internal variables are useless. They
    # care more about database attributes, which requires some extra steps to display
    # if I don't want to use `#inspect`.

    ##
    # Individual Active Record object is trivial. The object is a mapping from a DB
    # entity to Ruby object. It is always in the memory.
    class ActiveRecordBaseInspector
      include NestedHelper
      include ::RubyJard::Span::DSL

      def initialize(base)
        @base = base
      end

      def match?(variable)
        return false unless defined?(ActiveRecord::Base)

        RubyJard::Reflection.call_is_a?(variable, ActiveRecord::Base)
      end

      def inline(variable, line_limit:, depth: 0)
        row = SimpleRow.new(
          text_primary(RubyJard::Reflection.call_to_s(variable).chomp!('>')),
          text_primary(' ')
        )
        attributes = variable_attributes(variable)

        if attributes.nil?
          row << text_dim('??? failed to inspect attributes')
        else
          row << inline_pairs(
            attributes.each_with_index,
            total: attributes.length, line_limit: line_limit - row.content_length - 2,
            process_key: false, depth: depth + 1
          )
        end
        row << text_primary('>')
      end

      def multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        inline = inline(variable, line_limit: first_line_limit)
        return [inline] if inline.content_length < line_limit

        rows = [SimpleRow.new(
          text_primary(RubyJard::Reflection.call_to_s(variable))
        )]

        item_count = 0
        attributes = variable_attributes(variable)

        if attributes.nil?
          rows << SimpleRow.new(text_dim('  ▸ ??? failed to inspect attributes'))
        else
          attributes.each_with_index do |(key, value), index|
            rows << multiline_pair(
              key, value, line_limit: line_limit, process_key: false, depth: depth + 1
            )
            item_count += 1
            break if index >= lines - 2
          end
          if attributes.length > item_count
            rows << SimpleRow.new(text_dim("  ▸ #{attributes.length - item_count} more..."))
          end
        end
        rows
      end

      def variable_attributes(variable)
        variable.attributes
      rescue StandardError
        nil
      end
    end

    ##
    # When creating an active record relation, Rails won't trigger any SQL query, until
    # to_ary events. It is required to check for records loaded before recursively display
    # its children. Hint if the relation is not loaded yet.
    class ActiveRecordRelationInspector
      include NestedHelper
      include ::RubyJard::Span::DSL

      def initialize(base)
        @base = base
      end

      def match?(variable)
        return false unless defined?(ActiveRecord::Relation)

        RubyJard::Reflection.call_class(variable) < ActiveRecord::Relation
      rescue StandardError
        false
      end

      def inline(variable, line_limit:, depth: 0)
        if loaded?(variable)
          row = SimpleRow.new(text_primary(RubyJard::Reflection.call_to_s(variable).chomp('>')))
          row << text_primary(' ') if variable.length >= 1
          row << inline_values(
            variable.each_with_index,
            total: variable.length, line_limit: line_limit - row.content_length - 2,
            depth: depth + 1
          )
          row << text_primary('>')
          row << text_primary(' (empty)') if variable.length <= 0
          row
        else
          relation_summary(variable, line_limit)
        end
      end

      def multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        inline = inline(variable, line_limit: first_line_limit)
        if inline.content_length < line_limit
          [inline]
        elsif !loaded?(variable)
          [relation_summary(variable, first_line_limit)]
        else
          rows = [SimpleRow.new(text_primary(RubyJard::Reflection.call_to_s(variable)))]

          item_count = 0
          variable.each_with_index do |value, index|
            rows << multiline_value(value, line_limit: line_limit, depth: depth + 1)

            item_count += 1
            break if index >= lines - 2
          end
          if variable.length > item_count
            rows << SimpleRow.new(text_dim("  ▸ #{variable.length - item_count} more..."))
          end
          rows
        end
      end

      private

      def relation_summary(variable, line_limit)
        overview = RubyJard::Reflection.call_to_s(variable).chomp('>')
        width = overview.length + 1 + 12
        row = SimpleRow.new(text_primary(overview))
        if RubyJard::Reflection.call_respond_to?(variable, :to_sql) && width < line_limit
          detail = variable_sql(variable)
          detail = detail[0..line_limit - width - 2] + '…' if width + detail.length < line_limit
          row << text_dim(' ')
          row << text_dim(detail)
        end
        row << text_primary('>')
        row << text_dim(' (not loaded)')
        row
      end

      def loaded?(variable)
        variable.respond_to?(:loaded?) && variable.loaded?
      rescue StandardError
        false
      end

      def variable_sql(variable)
        variable.to_sql.inspect
      rescue StandardError
        'failed to inspect active relation\'s SQL'
      end
    end
  end
end
