# frozen_string_literal: true

RSpec.describe RubyJard::Commands::HideCommand do
  # Let's create a proper command object, with data injected
  subject(:command_object) do
    described_class.new(
      pry_instance: pry_instance, output: output,
      screens: screens,
      config: config
    )
  end

  let(:output) { StringIO.new }
  let(:pry_instance) { Pry.new(output: output) }
  let(:screens) { RubyJard::Screens.new }
  let(:config) { RubyJard::Config.new }

  before do
    %w[yarv source variables backtrace threads].each do |screen|
      screens.add_screen(screen, Class.new(RubyJard::Screen))
    end
  end

  context 'when no arguments are provided' do
    it 'returns error message, with a list of screens in ascending order' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line('hide')
        end
      end.to raise_error(
        ::Pry::CommandError,
        /Please input one of the following: backtrace, source, threads, variables, yarv/
      )
    end
  end

  context 'when screen not found' do
    it 'returns error message, with a list of screens in ascending order' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line('hide ahihi')
        end
      end.to raise_error(
        ::Pry::CommandError,
        /Screen `ahihi` not found. Please input one of the following: backtrace, source, threads, variables, yarv/
      )
    end
  end

  context 'when screen is already hidden' do
    before do
      config.enabled_screens = %w[source variables backtrace threads]
    end

    it 'does not update config but still dispatches a new flow' do
      flow = nil
      expect do
        flow = RubyJard::ControlFlow.listen do
          command_object.process_line('hide yarv')
        end
      end.not_to change(config, :enabled_screens)
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:list)
    end
  end

  context 'when screen is not hidden' do
    before do
      config.enabled_screens = %w[yarv source variables backtrace threads]
    end

    it 'updates config and dispatches a new flow' do
      flow = nil
      expect do
        flow = RubyJard::ControlFlow.listen do
          command_object.process_line('hide yarv')
        end
      end.to change(config, :enabled_screens).to(%w[source variables backtrace threads])
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:list)
    end
  end

  context 'when all screens are hidden' do
    before do
      config.enabled_screens = %w[]
    end

    it 'does not update config but still dispatches a new flow' do
      flow = nil
      expect do
        flow = RubyJard::ControlFlow.listen do
          command_object.process_line('hide yarv')
        end
      end.not_to change(config, :enabled_screens)
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:list)
    end
  end
end
