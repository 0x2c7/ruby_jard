# frozen_string_literal: true

RSpec.describe RubyJard::Commands::ExitCommand do
  subject(:command) { described_class.new }

  it 'dispatches exit flow without arguments' do
    flow = RubyJard::ControlFlow.listen do
      command.process_line('exit')
    end
    expect(flow).to be_a(::RubyJard::ControlFlow)
    expect(flow.command).to be(:exit)
    expect(flow.arguments).to eql({})
  end
end
