# frozen_string_literal: true

RSpec.describe RubyJard::Commands::SkipCommand do
  subject(:command_object) { described_class.new }

  it_behaves_like 'command with times', :skip, :skip do
  end

  context 'when call skip -a' do
    it 'dispatches skip flow with -1 argument' do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line('skip -a')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:skip)
      expect(flow.arguments).to eql({ times: -1 })
    end
  end

  context 'when call skip --all' do
    it 'dispatches skip flow with -1 argument' do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line('skip --all')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:skip)
      expect(flow.arguments).to eql({ times: -1 })
    end
  end
end
