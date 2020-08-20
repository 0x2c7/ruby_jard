# frozen_string_literal: true

RSpec.describe RubyJard::ThreadInfo do
  context 'when input invalid format' do
    it 'raises exception' do
      expect do
        described_class.new(1)
      end.to raise_error(RubyJard::Error, /Thread object/)
    end
  end

  describe '#id' do
    context 'when input thread is nil' do
      subject(:thread_info) { described_class.new(nil) }

      it 'returns nil' do
        expect(thread_info.id).to eq(nil)
      end
    end

    context 'when input thread is not nil' do
      subject(:thread_info) { described_class.new(Thread.current) }

      it 'returns underlying thread object_id' do
        expect(thread_info.id).to eq(Thread.current.object_id)
      end
    end
  end

  describe '#label' do
    before do
      described_class.clear_labels
    end

    it 'increases the label sequential' do
      expect(described_class.new(Thread.new {}).label).to eq('1')
      expect(described_class.new(Thread.new {}).label).to eq('2')
      expect(described_class.new(Thread.new {}).label).to eq('3')
      expect(described_class.new(Thread.new {}).label).to eq('4')
    end

    it 'reclaims exited label' do
      t1 = Thread.new {}
      t2 = Thread.new {}
      t3 = Thread.current

      expect(described_class.new(t1).label).to eq('1')
      expect(described_class.new(t2).label).to eq('2')
      expect(described_class.new(t1).label).to eq('1')
      expect(described_class.new(t2).label).to eq('2')

      expect(described_class.new(t3).label).to eq('3')
      expect(described_class.new(Thread.current).label).to eq('3')
    end

    context 'when input thread is nil' do
      it 'returns empty string' do
        expect(described_class.new(nil).label).to eq('')
      end
    end
  end

  describe '#name' do
    context 'when input thread is nil' do
      subject(:thread_info) { described_class.new(nil) }

      it 'returns nil' do
        expect(thread_info.name).to eq(nil)
      end
    end

    context 'when input thread does not have a name' do
      subject(:thread_info) { described_class.new(thread) }

      let(:thread) { Thread.new {} }

      it 'returns nil' do
        expect(thread_info.name).to eq(nil)
      end
    end

    context 'when input thread has a name' do
      subject(:thread_info) { described_class.new(thread) }

      let(:thread) { Thread.new {} }

      before do
        thread.name = 'This is a test thread'
      end

      it 'returns underlying thread name' do
        expect(thread_info.name).to eq('This is a test thread')
      end
    end
  end

  describe '#status' do
    context 'when input thread is nil' do
      subject(:thread_info) { described_class.new(nil) }

      it 'returns nil' do
        expect(thread_info.status).to eq(nil)
      end
    end

    context 'when input thread is running' do
      subject(:thread_info) { described_class.new(Thread.current) }

      it 'returns run' do
        expect(thread_info.status).to eq('run')
      end
    end

    context 'when input thread is sleeping' do
      subject(:thread_info) { described_class.new(thread) }

      let!(:thread) { Thread.new { sleep } }

      after do
        thread.exit
      end

      it 'returns sleep' do
        sleep 0.5
        expect(thread_info.status).to eq('sleep')
      end
    end

    context 'when input thread is exited' do
      subject(:thread_info) { described_class.new(thread) }

      let!(:thread) { Thread.new {} }

      before do
        thread.exit
      end

      it 'returns exited' do
        sleep 0.5
        expect(thread_info.status).to eq('exited')
      end
    end
  end

  describe '#alive?' do
    context 'when input thread is nil' do
      subject(:thread_info) { described_class.new(nil) }

      it 'returns false' do
        expect(thread_info.alive?).to eq(false)
      end
    end

    context 'when input thread is running' do
      subject(:thread_info) { described_class.new(Thread.current) }

      it 'returns true' do
        expect(thread_info.alive?).to eq(true)
      end
    end

    context 'when input thread is sleeping' do
      subject(:thread_info) { described_class.new(thread) }

      let!(:thread) { Thread.new { sleep } }

      after do
        thread.exit
      end

      it 'returns true' do
        sleep 0.5
        expect(thread_info.alive?).to eq(true)
      end
    end

    context 'when input thread is exited' do
      subject(:thread_info) { described_class.new(thread) }

      let!(:thread) { Thread.new {} }

      before do
        thread.exit
      end

      it 'returns false' do
        sleep 0.5
        expect(thread_info.alive?).to eq(false)
      end
    end
  end

  describe '#backtrace_locations' do
    context 'when input thread is nil' do
      subject(:thread_info) { described_class.new(nil) }

      it 'returns an empty array' do
        expect(thread_info.backtrace_locations).to eq([])
      end
    end

    context 'when input thread is running' do
      subject(:thread_info) { described_class.new(Thread.current) }

      it 'returns a real array' do
        expect(thread_info.backtrace_locations).to be_a(Array)
      end
    end

    context 'when input thread is exited' do
      subject(:thread_info) { described_class.new(thread) }

      let!(:thread) { Thread.new {} }

      before do
        thread.exit
      end

      it 'returns an empty array' do
        sleep 0.5
        expect(thread_info.backtrace_locations).to eq([])
      end
    end

  end

  describe '#==' do
    context 'when comparing with invalid type' do
      it 'raises exception' do
        expect do
          described_class.new(nil) == 'hello'
        end.to raise_error(RubyJard::Error, /invalid comparation/i)
      end
    end

    context 'when comparing with itself' do
      subject(:thread_info) { described_class.new(Thread.current) }

      it 'returns true' do
        expect(thread_info).to eq(thread_info)
      end
    end

    context 'when comparing with other thread info having same underlying thread' do
      let(:thread_info_1) { described_class.new(Thread.current) }
      let(:thread_info_2) { described_class.new(Thread.current) }

      it 'returns true' do
        expect(thread_info_1 == thread_info_2).to eq(true)
      end
    end

    context 'when comparing with other thread info having same underlying thread, different thread object' do
      let!(:thread) { Thread.current }
      let(:thread_info_1) { described_class.new(Thread.current) }
      let(:thread_info_2) { described_class.new(thread) }

      it 'returns true' do
        expect(thread_info_1 == thread_info_2).to eq(true)
      end
    end

    context 'when comparing with other different ThreadInfo' do
      let!(:thread) { Thread.new {} }
      let(:thread_info_1) { described_class.new(Thread.current) }
      let(:thread_info_2) { described_class.new(thread) }

      it 'returns false' do
        expect(thread_info_1 == thread_info_2).to eq(false)
      end
    end

    context 'when comparing with same underlying thread' do
      subject(:thread_info) { described_class.new(Thread.current) }

      it 'returns true' do
        expect(thread_info == Thread.current).to eq(true)
      end
    end

    context 'when comparing with same underlying thread, different object' do
      subject(:thread_info) { described_class.new(Thread.current) }

      it 'returns true' do
        t = Thread.current
        expect(thread_info == t).to eq(true)
      end
    end

    context 'when comparing with other underlying thread' do
      subject(:thread_info) { described_class.new(Thread.current) }

      it 'returns false' do
        expect(thread_info == Thread.new {}).to eq(false)
      end
    end
  end
end
