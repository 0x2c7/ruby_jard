# frozen_string_literal: true

RSpec.describe RubyJard::Commands::UpCommand do
  it 'dispatches up flow' do
    flow = RubyJard::ControlFlow.listen do
      subject.process_line('up')
    end
    expect(flow).to be_a(::RubyJard::ControlFlow)
    expect(flow.command).to eql(:up)
    expect(flow.arguments).to eql({})
  end
end
