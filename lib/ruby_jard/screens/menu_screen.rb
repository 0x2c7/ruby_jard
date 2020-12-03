# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Display key binding guidelines and shortcuts.
    class MenuScreen < RubyJard::Screen
      include ::RubyJard::Span::DSL

      def initialize(**args)
        super(**args)
        @key_bindings = @config.key_bindings
        @filter = @config.filter
        @filter_included = @config.filter_included
        @filter_excluded = @config.filter_excluded
        @selected = 0
      end

      def build
        left_spans = generate_left_spans
        right_spans = generate_right_spans
        @rows = [
          Row.new(
            Column.new(
              *[
                left_spans,
                align(left_spans, right_spans),
                right_spans
              ].flatten,
              word_wrap: RubyJard::Column::WORD_WRAP_BREAK_WORD
            )
          )
        ]
      end

      private

      def generate_left_spans
        key = key_binding('jard filter switch')
        filter_mode_span = text_special(
          "Filter#{key.nil? ? nil : " (#{key})"}: #{@filter.to_s.gsub(/_/, ' ').capitalize}"
        )
        filter_details =
          @filter_included.map { |f| "+#{f}" } +
          @filter_excluded.map { |f| "-#{f}" }
        if filter_details.empty?
          [filter_mode_span]
        else
          filter_exceprt = filter_details.first(3).join(' ')
          filter_more = filter_details.length > 3 ? " (#{filter_details.length - 3} more...)" : nil
          filter_details_span = text_primary(" #{filter_exceprt}#{filter_more}")
          [
            filter_mode_span,
            filter_details_span
          ]
        end
      end

      def generate_right_spans
        [
          ['step', 'Step'],
          ['step-out', 'Step Out'],
          ['next', 'Next'],
          ['continue', 'Continue']
        ].map do |command, command_label|
          key = key_binding(command)
          next if key.nil?

          menu_item = "#{command_label} (#{key})"
          text_primary("   #{menu_item}")
        end.compact
      end

      def align(left_spans, right_spans)
        alignment =
          @layout.width -
          right_spans.map(&:content_length).sum -
          left_spans.map(&:content_length).sum
        RubyJard::Span.new(
          content: ' ' * (alignment < 0 ? 0 : alignment),
          styles: :background
        )
      end

      def key_binding(command)
        key_binding = @key_bindings.key_bindings.find do |kb|
          kb.action == command
        end
        return nil if key_binding.nil?

        RubyJard::Keys::REVERSED_KEYS[key_binding.sequence]
      end
    end
  end
end

RubyJard::Screens.add_screen('menu', RubyJard::Screens::MenuScreen)
