# frozen_string_literal: true

RSpec.describe RubyJard::Commands::DownCommand do
  context '`down`' do
    it 'dispatches down flow with 1' do
      flow = RubyJard::ControlFlow.listen do
        subject.process_line("down")
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(:down)
      expect(flow.arguments).to eql({times: 1})
    end
  end

  context '`down 0`' do
    it "dispatches down flow with 0" do
      flow = RubyJard::ControlFlow.listen do
        subject.process_line('down 0')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(:down)
      expect(flow.arguments).to eql({times: 0})
    end
  end

  context '`down       3`' do
    it "dispatches down flow with 3" do
      flow = RubyJard::ControlFlow.listen do
        subject.process_line('down       3')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(:down)
      expect(flow.arguments).to eql({times: 3})
    end
  end

  context '`down 0030`' do
    it "dispatches down flow with 30" do
      flow = RubyJard::ControlFlow.listen do
        subject.process_line('down 0030')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(:down)
      expect(flow.arguments).to eql({times: 30})
    end
  end

  context '`down 3a`' do
    it "raises Pry::CommandError" do
      expect do
        flow = RubyJard::ControlFlow.listen do
          subject.process_line('down 3a')
        end
      end.to raise_error(::Pry::CommandError, /is not an integer/)
    end
  end
end
