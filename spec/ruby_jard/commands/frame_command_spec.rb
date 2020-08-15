# frozen_string_literal: true

RSpec.describe RubyJard::Commands::FrameCommand do
  subject(:command_object) { described_class.new(session: session) }

  let(:session) { RubyJard::Session.new }

  before do
    allow(session).to receive(:current_backtrace).and_return(
      Array.new(30, nil)
    )
  end

  context 'with `frame`' do
    it 'dispatches frame flow with 1' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line('frame')
        end
      end.to raise_error(::Pry::CommandError, /must be present/)
    end
  end

  context 'with `frame -2`' do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line('frame -2')
        end
      end.to raise_error(::Pry::CommandError, /must be positive/)
    end
  end

  context 'with `frame 1.1`' do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line('frame 1.1')
        end
      end.to raise_error(::Pry::CommandError, /is not an integer/)
    end
  end

  context 'with `frame       3`' do
    it 'dispatches frame flow with 3' do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line('frame       3')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:frame)
      expect(flow.arguments).to eql({ frame: 3 })
    end
  end

  context 'with `frame       +27`' do
    it 'dispatches frame flow with 3' do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line('frame       +27')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:frame)
      expect(flow.arguments).to eql({ frame: 27 })
    end
  end

  context 'with `frame 0027`' do
    it 'dispatches frame flow with 27' do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line('frame 0027')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:frame)
      expect(flow.arguments).to eql({ frame: 27 })
    end
  end

  context 'with `frame 3a`' do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line('frame 3a')
        end
      end.to raise_error(::Pry::CommandError, /is not an integer/)
    end
  end

  context 'with `frame 0` (first member)' do
    it 'raises Pry::CommandError' do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line('frame 0')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:frame)
      expect(flow.arguments).to eql({ frame: 0 })
    end
  end

  context 'with `frame 30` (out of range)' do
    it 'raises Pry::CommandError' do
      expect do
        RubyJard::ControlFlow.listen do
          command_object.process_line('frame 30')
        end
      end.to raise_error(::Pry::CommandError, /from 0 to 29/)
    end
  end

  context 'with `frame 29` (last member)' do
    it 'raises Pry::CommandError' do
      flow = RubyJard::ControlFlow.listen do
        command_object.process_line('frame 29')
      end
      expect(flow).to be_a(::RubyJard::ControlFlow)
      expect(flow.command).to be(:frame)
      expect(flow.arguments).to eql({ frame: 29 })
    end
  end
end
