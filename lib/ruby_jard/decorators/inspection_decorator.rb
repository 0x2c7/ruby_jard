# frozen_string_literal: true

module RubyJard
  # PP subclass for streaming inspect output in color.
  class InspectionDecorator < ::PP::SingleLine
    def self.inspect(obj, output = [], max_width = 79)
      queue = new(output, max_width)
      queue.guard_inspect_key { queue.pp obj }
      queue.flush

      queue.output.flatten
    end

    attr_reader :output

    def initialize(output, max_width = nil, new_line = nil)
      @output = output
      @first = [true]
      @max_width = max_width
      @width = 0
      @new_line = new_line
      @loc_decorator = RubyJard::Decorators::LocDecorator.new
    end

    def pp(object)
      return if @width > @max_width
      return super unless object.is_a?(String)

      puts @output.length
      text(object.inspect)
    end

    def text(str, _max_width = str.length)
      if str.start_with?('#<') || ['>'].include?(str)
        append_output(str, :object)
      elsif [' ', '=', '=>'].include?(str)
        append_output(str, :trivial_inspection)
      elsif str.start_with?("\e")
        append_output(str.gsub(/\e/i, '\e'), :trivial_inspection)
      else
        spans, _tokens = @loc_decorator.decorate(str)
        spans.each do |span|
          break if @width > @max_width

          @output << span
          @width += span.content_length
        end
      end
    end

    def breakable(sep = ' ', _width = nil)
      append_output(sep, :trivial_inspection)
    end

    def group(_indent = nil, open_obj = nil, close_obj = nil, _open_width = nil, _close_width = nil)
      @first.push true
      append_output(open_obj, :normal_token) unless open_obj.nil?
      yield
      append_output(close_obj, :normal_token) unless close_obj.nil?
      @first.pop
    end

    def append_output(str, style)
      return if str.empty?
      return if @width > @max_width

      @output << Span.new(
        span_template: nil,
        content: str,
        content_length: str.length,
        styles: { element: style }
      )
      @width += str.length
    end
  end
end
