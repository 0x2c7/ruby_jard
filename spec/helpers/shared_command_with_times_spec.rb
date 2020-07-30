# frozen_string_literal: true

RSpec.shared_examples 'command with times' do |command_text, command_flow|
  context "with `#{command_text}`" do
    it "dispatches #{command_text} flow with 1" do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line(command_text.to_s)
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(command_flow)
      expect(flow.arguments).to eql({ times: 1 })
    end
  end

  context "with `#{command_text} 0`" do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line("#{command_text} 0")
        end
      end.to raise_error(::Pry::CommandError, /must be positive/)
    end
  end

  context "with `#{command_text} -2`" do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line("#{command_text} -2")
        end
      end.to raise_error(::Pry::CommandError, /must be positive/)
    end
  end

  context "with `#{command_text} 1.1`" do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line("#{command_text} 1.1")
        end
      end.to raise_error(::Pry::CommandError, /is not an integer/)
    end
  end

  context "with `#{command_text}       3`" do
    it "dispatches #{command_text} flow with 3" do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line("#{command_text}       3")
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(command_flow)
      expect(flow.arguments).to eql({ times: 3 })
    end
  end

  context "with `#{command_text}       +33`" do
    it "dispatches #{command_text} flow with 3" do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line("#{command_text}       +33")
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(command_flow)
      expect(flow.arguments).to eql({ times: 33 })
    end
  end

  context "with `#{command_text} 0030`" do
    it "dispatches #{command_text} flow with 30" do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line("#{command_text} 0030")
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to eql(command_flow)
      expect(flow.arguments).to eql({ times: 30 })
    end
  end

  context "with `#{command_text} 3a`" do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line("#{command_text} 3a")
        end
      end.to raise_error(::Pry::CommandError, /is not an integer/)
    end
  end
end
