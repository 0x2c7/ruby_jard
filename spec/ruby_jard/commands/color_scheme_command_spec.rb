# frozen_string_literal: true

RSpec.describe RubyJard::Commands::ColorSchemeCommand do
  subject(:command_object) { described_class.new(pry_instance: pry_instance) }

  let!(:input) { InputTester.new 'color-scheme -l' }
  let!(:output) { StringIO.new }
  let!(:pry_instance) { Pry.new(output: output) }

  before do
    allow(described_class).to receive(:session_backtrace).and_return(
      Array.new(30, nil)
    )
  end

  context 'with `color-scheme -l`' do
    context 'when no theme available' do
      before do
        allow(described_class).to receive(:color_scheme_names).and_return([])
      end

      it 'returns info message' do
        redirect_pry_io(input, output) { command_object.process_line 'color-scheme -l' }
        expect(output.string).to match(/No loaded color schemes/)
      end
    end

    context 'when some themes are available' do
      before do
        allow(described_class).to receive(:color_scheme_names).and_return(
          %w[256 deep-space gruvbox monokai]
        )
      end

      it 'returns a list of color scheme' do
        redirect_pry_io(input, output) { command_object.process_line 'color-scheme -l' }
        expect(output.string).to eql(
          <<~OUTPUT
            256
            deep-space
            gruvbox
            monokai
          OUTPUT
        )
      end
    end
  end

  context 'with `color-scheme`' do
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
      before do
        allow(described_class).to receive(:color_scheme_names).and_return(
          %w[256 deep-space gruvbox monokai]
        )
        allow(described_class).to receive(:get_color_scheme).and_return(
          nil
        )
      end

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
        allow(described_class).to receive(:color_scheme_names).and_return(
          %w[256 deep-space gruvbox monokai]
        )
        allow(described_class).to receive(:get_color_scheme).and_return(
          'gruvbox'
        )
      end

      it 'returns error message' do
        flow = RubyJard::ControlFlow.listen do
          command_object.process_line('color-scheme gruvbox')
        end
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:color_scheme)
        expect(flow.arguments).to eql({ color_scheme: 'gruvbox' })
      end
    end
  end
end
