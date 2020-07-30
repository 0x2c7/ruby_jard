# frozen_string_literal: true

RSpec.describe RubyJard::Commands::UpCommand do
  context '`up`' do
    it 'dispatches up flow with 1' do
      flow = RubyJard::ControlFlow.listen do
        subject.process_line("up")
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(:up)
      expect(flow.arguments).to eql({times: 1})
    end
  end

  context '`up 0`' do
    it "dispatches up flow with 0" do
      flow = RubyJard::ControlFlow.listen do
        subject.process_line('up 0')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(:up)
      expect(flow.arguments).to eql({times: 0})
    end
  end

  context '`up       3`' do
    it "dispatches up flow with 3" do
      flow = RubyJard::ControlFlow.listen do
        subject.process_line('up       3')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(:up)
      expect(flow.arguments).to eql({times: 3})
    end
  end

  context '`up 0030`' do
    it "dispatches up flow with 30" do
      flow = RubyJard::ControlFlow.listen do
        subject.process_line('up 0030')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(:up)
      expect(flow.arguments).to eql({times: 30})
    end
  end

  context '`up 3a`' do
    it "raises Pry::CommandError" do
      expect do
        flow = RubyJard::ControlFlow.listen do
          subject.process_line('up 3a')
        end
      end.to raise_error(::Pry::CommandError, /is not an integer/)
    end
  end
end
