# frozen_string_literal: true

RSpec.describe RubyJard::Commands::NextCommand do
  subject(:command) { described_class.new }

  context 'with `next`' do
    it 'dispatches next flow with 1' do
      flow = RubyJard::ControlFlow.listen do
        command.process_line('next')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:next)
      expect(flow.arguments).to eql({ times: 1 })
    end
  end

  context 'with `next 0`' do
    it 'dispatches next flow with 0' do
      flow = RubyJard::ControlFlow.listen do
        command.process_line('next 0')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:next)
      expect(flow.arguments).to eql({ times: 0 })
    end
  end

  context 'with `next       3`' do
    it 'dispatches next flow with 3' do
      flow = RubyJard::ControlFlow.listen do
        command.process_line('next       3')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:next)
      expect(flow.arguments).to eql({ times: 3 })
    end
  end

  context 'with `next 0030`' do
    it 'dispatches next flow with 30' do
      flow = RubyJard::ControlFlow.listen do
        command.process_line('next 0030')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:next)
      expect(flow.arguments).to eql({ times: 30 })
    end
  end

  context 'with `next 3a`' do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command.process_line('next 3a')
        end
      end.to raise_error(::Pry::CommandError, /is not an integer/)
    end
  end
end
