# frozen_string_literal: true

RSpec.describe RubyJard::Commands::ContinueCommand do
  subject(:command) { described_class.new }

  it 'dispatches continue flow without arguments' do
    flow = RubyJard::ControlFlow.listen do
      command.process_line('continue')
    end
    expect(flow).to be_a(::RubyJard::ControlFlow)
    expect(flow.command).to be(:continue)
    expect(flow.arguments).to eql({})
  end
end
