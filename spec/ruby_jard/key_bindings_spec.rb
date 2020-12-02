# frozen_string_literal: true

RSpec.describe RubyJard::KeyBindings do
  let(:sample_sequences) do
    {
      "\eOQ"     => 'jard filter switch',
      "\e[15~"   => 'list',
      "\e[17~"   => 'up',
      "\e[17;2~" => 'down',
      "\e[18;2~" => 'step'
    }
  end

  describe '#initialize' do
    context 'when where is no input sequence' do
      it 'reset indexs to an empty hash' do
        key_bindings = described_class.new
        expect(key_bindings.indexes).to eql({})
      end
    end

    context 'when there are some input sequences' do
      it 'establishes the indexes for input sequences' do
        key_bindings = described_class.new(sample_sequences)
        expect(key_bindings.indexes.keys).not_to eql([])
      end
    end
  end

  describe '#match' do
    let(:key_bindings) { described_class.new(sample_sequences) }

    context 'when input keys do not match any key binding' do
      it 'returns all keys after the first read' do
        keys = ["\f1234", '56']
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to eql("\f1234")
      end
    end

    context 'when input keys do not match any key binding after multiple reads' do
      it 'returns all keys after the first read' do
        keys = ["\e[18;", '3~']
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to eql("\e[18;3~")
      end
    end

    context 'when input keys match a part of a key binding' do
      it 'returns all keys' do
        keys = ["\e[17", nil]
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to eql("\e[17")
      end
    end

    context 'when input keys match an unique key binding' do
      it 'returns a key binding object' do
        keys = ["\eOQ", nil]
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to be_a(RubyJard::KeyBinding)
        expect(read_keys.action).to eql('jard filter switch')
      end
    end

    context 'when input keys match a key binding' do
      it 'returns a key binding object' do
        keys = ["\e[17~", nil]
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to be_a(RubyJard::KeyBinding)
        expect(read_keys.action).to eql('up')
      end
    end

    context 'when input keys match the longer key binding' do
      it 'returns the longer key binding object' do
        keys = ["\e[17;2~", nil]
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to be_a(RubyJard::KeyBinding)
        expect(read_keys.action).to eql('down')
      end
    end

    context 'when input keys match a key binding after multiple reads' do
      it 'returns a key binding object' do
        keys = ["\e[1", '7~']
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to be_a(RubyJard::KeyBinding)
        expect(read_keys.action).to eql('up')
      end
    end

    context 'when input keys match the longer key binding after multiple reads' do
      it 'returns the longer key binding object' do
        keys = ["\e[17;", '2~']
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to be_a(RubyJard::KeyBinding)
        expect(read_keys.action).to eql('down')
      end
    end

    context 'when input keys have trailing charcters after a valid key binding' do
      it 'returns discards trailing charcters' do
        keys = ["\e[17~abcdef"]
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to be_a(RubyJard::KeyBinding)
        expect(read_keys.action).to eql('up')
      end
    end

    context 'when input keys have trailing charcters after a valid key binding after multiple reads' do
      it 'returns discards trailing charcters' do
        keys = ["\e[1", '7~abcdef']
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to be_a(RubyJard::KeyBinding)
        expect(read_keys.action).to eql('up')
      end
    end

    context 'when input keys include multiple key bindings' do
      it 'returns the first key binding object' do
        keys = ["\e[1", "7~\e[18;2~"]
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to be_a(RubyJard::KeyBinding)
        expect(read_keys.action).to eql('up')
      end
    end

    context 'when input keys has prefixed charcters' do
      it 'returns all the keys by design' do
        keys = ["123\e[17~"]
        read_keys = key_bindings.match { keys.shift }
        expect(read_keys).to eql("123\e[17~")
      end
    end
  end
end
