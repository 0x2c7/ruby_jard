# frozen_string_literal: true

RSpec.describe RubyJard::Commands::ColorSchemeCommand do
  # Let's create a proper command object, with data injected
  subject(:command_object) do
    described_class.new(
      pry_instance: pry_instance, output: output,
      color_schemes: color_schemes,
      config: config
    )
  end

  let(:scheme_class) do
    Class.new(RubyJard::ColorScheme) do
      const_set(:STYLES, { text_normal: [] })
    end
  end

  let(:output) { StringIO.new }
  let(:pry_instance) { Pry.new(output: output) }
  let(:color_schemes) { RubyJard::ColorSchemes.new }
  let(:config) { RubyJard::Config.new }

  context 'with `color-scheme -l`' do
    context 'when no theme available' do
      it 'returns info message' do
        command_object.process_line 'color-scheme -l'
        expect(output.string).to match(/No loaded color schemes/)
      end
    end

    context 'when some themes are available' do
      before do
        %w[256 deep-space gruvbox monokai].each do |scheme|
          color_schemes.add_color_scheme(scheme, scheme_class)
        end
      end

      it 'returns a list of color scheme' do
        command_object.process_line 'color-scheme -l'
        expect(output.string.strip).to eql(
          <<~OUTPUT.strip
            4 available color schemes

            256        | ⬤

            deep-space | ⬤

            gruvbox    | ⬤

            monokai    | ⬤
          OUTPUT
        )
      end
    end
  end

  context 'with `color-scheme`' do
    before do
      %w[256 deep-space gruvbox monokai].each do |scheme|
        color_schemes.add_color_scheme(scheme, scheme_class)
      end
    end

    context 'when no arguments are provided' do
      it 'returns error message' do
        expect do
          RubyJard::ControlFlow.listen do
            command_object.process_line('color-scheme')
          end
        end.to raise_error(::Pry::CommandError, /must provide a color scheme/)
      end
    end

    context 'when color scheme not found' do
      it 'returns error message' do
        expect do
          RubyJard::ControlFlow.listen do
            command_object.process_line('color-scheme blahblah')
          end
        end.to raise_error(::Pry::CommandError, /not found/)
      end
    end

    context 'when color scheme is found' do
      before do
        config.color_scheme = 'default_scheme'
      end

      it 'updates config, and dispatches a new flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line('color-scheme gruvbox')
          end
        end.to change(config, :color_scheme).from('default_scheme').to('gruvbox')
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end
  end
end
