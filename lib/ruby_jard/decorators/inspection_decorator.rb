# frozen_string_literal: true

module RubyJard
  ##
  # Generate beauty inspection of a particular variable.
  # The inspection doesn't aim to become a better version of PP. Instead,
  # it's scope is to generate an overview of a variable within a limited
  # space. So, it only keeps useful information, and tries to reach the
  # very shallow layers of a nested data structure.
  # This class is inspired by Ruby's PP:
  # https://github.com/ruby/ruby/blob/master/lib/pp.rb
  class InspectionDecorator
    PRIMITIVE_TYPES = {
      # Intertal classes for those values may differ between Ruby versions
      # For example: Bignum is renamed to Integer
      # So, it's safer to use discrete value's class as the key for this mapping.
      true.class.name => :literal,
      false.class.name => :literal,
      1.class.name => :literal,
      1.1.class.name => :literal,
      1.to_r.class.name => :literal, # Rational: (1/1)
      1.to_c.class.name => :literal, # Complex: (1+0i)
      :sym.class.name => :literal,
      //.class.name => :literal,
      (0..0).class.name => :literal,
      nil.class.name => :text_dim,
      Class.class.name => :constant # Sorry, I lied, Class will never change
    }.freeze

    OBJECT_ADDRESS_PATTERN = /#<(.*)(:0x[0-9]+.*)>/i.freeze

    def initialize; end

    def decorate(variable, hard_limit)
      if primitive?(variable)
        RubyJard::Span.new(
          content: variable.inspect[0..hard_limit],
          styles: PRIMITIVE_TYPES[variable.class.name]
        )
      elsif variable.is_a?(Array)
        decorate_array(variable, hard_limit)
      elsif variable.is_a?(Hash)
        decorate_hash(variable, hard_limit)
      elsif variable.is_a?(Struct)
        decorate_struct(variable, hard_limit)
      elsif variable.is_a?(String)
        decorate_string(variable, hard_limit)
      else
        decorate_object(variable, hard_limit)
      end
    end

    def primitive?(variable)
      !PRIMITIVE_TYPES[variable.class.name].nil?
    end

    def decorate_array(variable, hard_limit)
      spans = [RubyJard::Span.new(content: '[', styles: :text_dim)]
      width = 1
      variable.each_with_index do |item, index|
        item_limit = [hard_limit / variable.length, 30].max
        inspection = decorate(item, item_limit)
        if width + content_length(inspection) > hard_limit - 3
          spans << RubyJard::Span.new(content: '...', styles: :text_dim)
          break
        end
        spans << inspection
        width += content_length(inspection)
        if index < variable.length - 1
          spans << RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_dim)
          width += 2
        end
      end
      spans << RubyJard::Span.new(content: ']', styles: :text_dim)
      spans.flatten
    end

    def decorate_hash(variable, hard_limit)
      spans = [RubyJard::Span.new(content: '{', styles: :text_dim)]
      width = 1
      variable.each_with_index do |(key, value), index|
        item_limit = [hard_limit / variable.length / 2, 30].max
        key_inspection = decorate(key, item_limit)
        value_inspection = decorate(value, [item_limit - content_length(key_inspection), 30].max)

        if width + content_length(key_inspection) + content_length(value_inspection) > hard_limit - 6
          spans << RubyJard::Span.new(content: '...', styles: :text_dim)
          break
        end
        spans << key_inspection
        width += content_length(key_inspection)

        spans << RubyJard::Span.new(content: '→', margin_left: 1, margin_right: 1, styles: :text_highlighted)
        width += 3

        spans << value_inspection
        width += content_length(value_inspection)

        if index < variable.length - 1
          spans << RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_dim)
          width += 2
        end
      end
      spans << RubyJard::Span.new(content: '}', styles: :text_dim)
      spans.flatten
    end

    def decorate_struct(variable, hard_limit)
      spans = [RubyJard::Span.new(content: '#<struct ', styles: :text_dim)]
      unless variable.class.name.nil?
        spans << RubyJard::Span.new(content: "#{variable.class.name} ", styles: :text_dim)
      end
      width = content_length(spans)

      variable.members.each_with_index do |member, index|
        item_limit = [hard_limit / variable.members.length - member.length, 30].max
        inspection = decorate(variable[member], item_limit)

        if width + member.length + content_length(inspection) > hard_limit - 6
          spans << RubyJard::Span.new(content: '...', styles: :text_dim)
          break
        end
        spans << RubyJard::Span.new(content: member, styles: :text_secondary)
        width += member.length

        spans << RubyJard::Span.new(content: '→', margin_left: 1, margin_right: 1, styles: :text_highlighted)
        width += 3

        spans << inspection
        width += content_length(inspection)

        if index < variable.length - 1
          spans << RubyJard::Span.new(content: ', ', styles: :text_dim)
          width += 1
        end
      end
      spans << RubyJard::Span.new(content: '>', styles: :text_dim)
      spans.flatten
    end

    def decorate_string(variable, hard_limit)
      str =
        if variable.length < hard_limit
          variable
        else
          variable[0..hard_limit - 2].inspect[1..-1].chomp!('"')[0..hard_limit - 3] + '»'
        end
      spans = [RubyJard::Span.new(content: '"', styles: :text_secondary)]
      spans << RubyJard::Span.new(content: str, styles: :text_secondary)
      spans << RubyJard::Span.new(content: '"', styles: :text_secondary)
    end

    def decorate_object(variable, hard_limit)
      object_address = variable.to_s
      match = object_address.match(OBJECT_ADDRESS_PATTERN)
      if match
        decorate_object_address(match[1], match[2], hard_limit)
      elsif object_address.length <= hard_limit
        RubyJard::Span.new(
          content: object_address[0..hard_limit],
          styles: :text_secondary
        )
      else
        RubyJard::Span.new(
          content: object_address[0..hard_limit - 3] + '...',
          styles: :text_secondary
        )
      end
    end

    private

    def content_length(spans)
      if spans.is_a?(Array)
        spans.map(&:content_length).sum
      else
        spans.content_length
      end
    end

    def decorate_object_address(overview, detail, hard_limit)
      detail =
        if detail.length < hard_limit - overview.length - 3
          detail
        else
          detail[0..hard_limit - overview.length - 6] + '...'
        end
      [
        RubyJard::Span.new(
          content: '#<',
          styles: :text_dim
        ),
        RubyJard::Span.new(
          content: overview,
          styles: :text_secondary
        ),
        RubyJard::Span.new(
          content: detail,
          styles: :text_dim
        ),
        RubyJard::Span.new(
          content: '>',
          styles: :text_dim
        )
      ]
    end
  end
end
