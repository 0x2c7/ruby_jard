# frozen_string_literal: true

RSpec.describe RubyJard::ReplSequence do
  describe '#encode' do
    context 'when command is nil' do
      it 'returns an empty string' do
        expect(described_class.encode(nil)).to eql('')
      end
    end

    context 'when command is empty' do
      it 'returns an empty string' do
        expect(described_class.encode('')).to eql('')
      end
    end

    context 'when command is present' do
      it 'returns escaped sequence' do
        expect(described_class.encode('hello')).to eql('\e]711;Command~hello;')
      end
    end
  end

  describe '#detect' do
    context 'when content is empty' do
      it 'returns nil' do
        expect(described_class.detect('')).to be(nil)
      end
    end

    context 'when content is nil' do
      it 'returns nil' do
        expect(described_class.detect(nil)).to be(nil)
      end
    end

    context 'when content does not contain an escaped sequence' do
      it 'returns nil' do
        expect(described_class.detect('hello 123')).to be(nil)
      end
    end

    context 'when content contains an empty escaped sequence' do
      it 'returns nil' do
        expect(described_class.detect('\e]711;Command~')).to be(nil)
      end
    end

    context 'when content contains a valid escaped sequence' do
      it 'returns mentioned command' do
        expect(described_class.detect('1251\e]711;Command~list;abcabc')).to eql('list')
      end
    end

    context 'when content contains an escaped sequence with spaces' do
      it 'returns mentioned command' do
        expect(
          described_class.detect('1251\e]711;Command~jard filter switch;abcabc')
        ).to eql('jard filter switch')
      end
    end

    context 'when content contains multiple escaped sequences' do
      it 'returns first mentioned command' do
        expect(
          described_class.detect('1251\e]711;Command~list;abcabc\e]711;Command~patch;123')
        ).to eql('list')
      end
    end
  end
end
