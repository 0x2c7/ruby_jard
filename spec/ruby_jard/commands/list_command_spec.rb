# frozen_string_literal: true

RSpec.describe RubyJard::Commands::ListCommand do
  subject(:command) { described_class.new }

  it 'dispatches list flow without arguments' do
    flow = RubyJard::ControlFlow.listen do
      command.process_line('list')
    end
    expect(flow).to be_a(::RubyJard::ControlFlow)
    expect(flow.command).to be(:list)
    expect(flow.arguments).to eql({})
  end
end
