# frozen_string_literal: true

def color_decorator_test_case_name(test_case)
  "when translated style is #{test_case[:input][0].inspect} "\
    "and content is #{test_case[:input][1].inspect}"
end

RSpec.describe RubyJard::Decorators::ColorDecorator do
  subject(:color_decorator) { described_class.new(color_scheme) }

  let(:color_scheme) do
    Class.new(RubyJard::ColorScheme) do
      const_set(
        :STYLES,
        {
          color0: [],
          color1: ['234'],
          color2: ['#aaa'], # 170, 170, 170
          color3: ['#80b57b'], # 128, 181, 123
          color4: %w[234 245],
          color5: ['#bbb', '#aaa'], # 187, 187, 187 and 170, 170, 170
          color6: ['#80b57b', '#78b5ff'], # 128, 181, 123 and 120, 181, 255
          color_not_supported_1: ['rgb(0, 255, 255)'],
          color_not_supported_2: ['rgb(0, 255, 255)', 'rgb(0, 255, 255)'],
          color_invalid: 'invalid'
        }.freeze
      )
    end.new
  end

  [
    # Input style is a symbol
    { input: [:color0, nil], output: "\e[0m" },
    { input: [:color0, 'hello'], output: "hello\e[0m" },
    { input: [:color1, nil], output: "\e[38;5;234m\e[0m" },
    { input: [:color1, 'hello'], output: "\e[38;5;234mhello\e[0m" },
    { input: [:color2, nil], output: "\e[38;2;170;170;170m\e[0m" },
    { input: [:color2, 'hello'], output: "\e[38;2;170;170;170mhello\e[0m" },
    { input: [:color3, nil], output: "\e[38;2;128;181;123m\e[0m" },
    { input: [:color3, 'hello'], output: "\e[38;2;128;181;123mhello\e[0m" },
    { input: [:color4, nil], output: "\e[38;5;234m\e[48;5;245m\e[0m" },
    { input: [:color4, 'hello'], output: "\e[38;5;234m\e[48;5;245mhello\e[0m" },
    { input: [:color5, nil], output: "\e[38;2;187;187;187m\e[48;2;170;170;170m\e[0m" },
    { input: [:color5, 'hello'], output: "\e[38;2;187;187;187m\e[48;2;170;170;170mhello\e[0m" },
    { input: [:color6, nil], output: "\e[38;2;128;181;123m\e[48;2;120;181;255m\e[0m" },
    { input: [:color6, 'hello'], output: "\e[38;2;128;181;123m\e[48;2;120;181;255mhello\e[0m" },
    { input: [:color_not_supported_1, nil], output: "\e[0m" },
    { input: [:color_not_supported_1, 'hello'], output: "hello\e[0m" },
    { input: [:color_not_supported_2, nil], output: "\e[0m" },
    { input: [:color_not_supported_2, 'hello'], output: "hello\e[0m" },
    { input: [:color_invalid, nil], error: /must be an array/ },
    { input: [:color_not_found, nil], output: "\e[0m" },
    # Input style is an array with single symbol
    { input: [[:color0], nil], output: "\e[0m" },
    { input: [[:color0], 'hello'], output: "hello\e[0m" },
    { input: [[:color1], nil], output: "\e[38;5;234m\e[0m" },
    { input: [[:color1], 'hello'], output: "\e[38;5;234mhello\e[0m" },
    { input: [[:color2], nil], output: "\e[38;2;170;170;170m\e[0m" },
    { input: [[:color2], 'hello'], output: "\e[38;2;170;170;170mhello\e[0m" },
    { input: [[:color3], nil], output: "\e[38;2;128;181;123m\e[0m" },
    { input: [[:color3], 'hello'], output: "\e[38;2;128;181;123mhello\e[0m" },
    { input: [[:color4], nil], output: "\e[38;5;234m\e[48;5;245m\e[0m" },
    { input: [[:color4], 'hello'], output: "\e[38;5;234m\e[48;5;245mhello\e[0m" },
    { input: [[:color5], nil], output: "\e[38;2;187;187;187m\e[48;2;170;170;170m\e[0m" },
    { input: [[:color5], 'hello'], output: "\e[38;2;187;187;187m\e[48;2;170;170;170mhello\e[0m" },
    { input: [[:color6], nil], output: "\e[38;2;128;181;123m\e[48;2;120;181;255m\e[0m" },
    { input: [[:color6], 'hello'], output: "\e[38;2;128;181;123m\e[48;2;120;181;255mhello\e[0m" },
    { input: [[:color_not_supported_1], nil], output: "\e[0m" },
    { input: [[:color_not_supported_1], 'hello'], output: "hello\e[0m" },
    { input: [[:color_not_supported_2], nil], output: "\e[0m" },
    { input: [[:color_not_supported_2], 'hello'], output: "hello\e[0m" },
    { input: [[:color_invalid], nil], error: /must be an array/ },
    { input: [[:color_not_found], nil], output: "\e[0m" },
    # Input style includes text attributes
    { input: [[:color0, :underline], nil], output: "\e[4m\e[0m" },
    { input: [[:color0, :underline], 'hello'], output: "\e[4mhello\e[0m" },
    { input: [[:color1, :underline], nil], output: "\e[38;5;234m\e[4m\e[0m" },
    { input: [[:color1, :underline], 'hello'], output: "\e[38;5;234m\e[4mhello\e[0m" },
    { input: [[:color2, :underline], nil], output: "\e[38;2;170;170;170m\e[4m\e[0m" },
    { input: [[:color2, :underline], 'hello'], output: "\e[38;2;170;170;170m\e[4mhello\e[0m" },
    { input: [[:color3, :underline], nil], output: "\e[38;2;128;181;123m\e[4m\e[0m" },
    { input: [[:color3, :underline], 'hello'], output: "\e[38;2;128;181;123m\e[4mhello\e[0m" },
    { input: [[:color4, :underline], nil], output: "\e[38;5;234m\e[48;5;245m\e[4m\e[0m" },
    { input: [[:color4, :underline], 'hello'], output: "\e[38;5;234m\e[48;5;245m\e[4mhello\e[0m" },
    { input: [[:color5, :underline], nil], output: "\e[38;2;187;187;187m\e[48;2;170;170;170m\e[4m\e[0m" },
    { input: [[:color5, :underline], 'hello'], output: "\e[38;2;187;187;187m\e[48;2;170;170;170m\e[4mhello\e[0m" },
    { input: [[:color6, :underline], nil], output: "\e[38;2;128;181;123m\e[48;2;120;181;255m\e[4m\e[0m" },
    { input: [[:color6, :underline], 'hello'], output: "\e[38;2;128;181;123m\e[48;2;120;181;255m\e[4mhello\e[0m" },
    { input: [[:color_not_supported_1, :underline], nil], output: "\e[4m\e[0m" },
    { input: [[:color_not_supported_1, :underline], 'hello'], output: "\e[4mhello\e[0m" },
    { input: [[:color_not_supported_2, :underline], nil], output: "\e[4m\e[0m" },
    { input: [[:color_not_supported_2, :underline], 'hello'], output: "\e[4mhello\e[0m" },
    { input: [[:color_invalid, :underline], nil], error: /must be an array/ },
    { input: [[:color_not_found, :underline], nil], output: "\e[4m\e[0m" },
    # Completed example
    {
      input: [[:color4, :underline, :bold, :italic], '#<Thread:0x000055fcf5f64c38@Super thread test1.rb:78 sleep>'],
      output: "\e[38;5;234m\e[48;5;245m\e[4m\e[1m\e[3m#<Thread:0x000055fcf5f64c38@Super thread test1.rb:78 sleep>\e[0m"
    }
  ].each do |test_case|
    context color_decorator_test_case_name(test_case) do
      it do
        if test_case[:error]
          expect do
            color_decorator.decorate(*test_case[:input])
          end.to raise_error(RubyJard::Error, test_case[:error])
        else
          expect(color_decorator.decorate(*test_case[:input])).to eql(test_case[:output])
        end
      end
    end
  end
end
