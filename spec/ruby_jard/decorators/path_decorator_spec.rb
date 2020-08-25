# frozen_string_literal: true

RSpec.describe RubyJard::Decorators::PathDecorator do
  subject(:decorator) { described_class.new(path_classifier: classifier) }

  let(:classifier) { RubyJard::PathClassifier.new }

  context 'when input path is nil' do
    it 'returns ???' do
      expect(decorator.decorate(nil, 0)).to eql(['at ???', 'at ???'])
    end
  end

  context 'when input path is source tree type' do
    let(:dir) { Dir.pwd }

    before do
      allow(classifier).to receive(:classify).and_return([:source_tree])
    end

    context 'when input path is absent' do
      let(:path) { "#{dir}/abc/def.rb" }

      it do
        expect(decorator.decorate(path)).to eql(['at abc/def.rb', 'abc/def.rb'])
      end
    end

    context 'when input path is in a sub-folder' do
      let(:path) { "#{dir}/abc/def.rb" }

      it do
        expect(decorator.decorate(path, 123)).to eql(['at abc/def.rb:123', 'abc/def.rb:123'])
      end
    end

    context 'when input path is directly in current source tree' do
      let(:path) { "#{dir}/def.rb" }

      it do
        expect(decorator.decorate(path, 123)).to eql(['at def.rb:123', 'def.rb:123'])
      end
    end

    context 'when input path is relative path' do
      let(:path) { './abc/def.rb' }

      it do
        expect(decorator.decorate(path, 123)).to eql(['at abc/def.rb:123', 'abc/def.rb:123'])
      end
    end
  end

  context 'when input path is a gem' do
    let(:dir) { Gem.path.first }
    let(:path) { "#{dir}/gems/jard_merge_sort-0.1.0/lib/jard_merge_sort/spell_checker.rb" }

    context 'when gem has version' do
      before do
        allow(classifier).to receive(:classify).and_return(
          [:gem, 'jard_merge_sort', '1.2.0', 'lib/jard_merge_sort/spell_checker.rb']
        )
      end

      it do
        expect(decorator.decorate(path, 123)).to eql(
          ['in <jard_merge_sort 1.2.0>', '<jard_merge_sort:lib/jard_merge_sort/spell_checker.rb:123>']
        )
      end
    end

    context 'when input line is absent' do
      before do
        allow(classifier).to receive(:classify).and_return(
          [:gem, 'jard_merge_sort', '1.2.0', 'lib/jard_merge_sort/spell_checker.rb']
        )
      end

      it do
        expect(decorator.decorate(path)).to eql(
          ['in <jard_merge_sort 1.2.0>', '<jard_merge_sort:lib/jard_merge_sort/spell_checker.rb>']
        )
      end
    end

    context 'when gem version is absent' do
      before do
        allow(classifier).to receive(:classify).and_return(
          [:gem, 'jard_merge_sort', nil, 'lib/jard_merge_sort/spell_checker.rb']
        )
      end

      it do
        expect(decorator.decorate(path, 123)).to eql(
          ['in <jard_merge_sort>', '<jard_merge_sort:lib/jard_merge_sort/spell_checker.rb:123>']
        )
      end
    end

    context 'when gem version is absent and input line is absent' do
      before do
        allow(classifier).to receive(:classify).and_return(
          [:gem, 'jard_merge_sort', nil, 'lib/jard_merge_sort/spell_checker.rb']
        )
      end

      it do
        expect(decorator.decorate(path)).to eql(
          ['in <jard_merge_sort>', '<jard_merge_sort:lib/jard_merge_sort/spell_checker.rb>']
        )
      end
    end
  end

  context 'when path is in standard lib' do
    let(:path) { Gem.method(:path).source_location.first }

    before do
      allow(classifier).to receive(:classify).and_return(
        [:stdlib, 'rubygems', 'rubygems.rb']
      )
    end

    context 'when input line is present' do
      it do
        expect(decorator.decorate(path, 123)).to eql(
          ['in <stdlib:rubygems>', '<stdlib:rubygems.rb:123>']
        )
      end
    end

    context 'when input line is absent' do
      it do
        expect(decorator.decorate(path)).to eql(
          ['in <stdlib:rubygems>', '<stdlib:rubygems.rb>']
        )
      end
    end
  end

  context 'when path is internal' do
    before do
      allow(classifier).to receive(:classify).and_return([:internal])
    end

    context 'when input line is present' do
      it do
        expect(decorator.decorate('<internal:gc>', 123)).to eql(
          ['in <internal:gc>', '<internal:gc>']
        )
      end
    end

    context 'when input line is absent' do
      it do
        expect(decorator.decorate('<internal:gc>')).to eql(
          ['in <internal:gc>', '<internal:gc>']
        )
      end
    end
  end

  context 'when path is evaluation' do
    before do
      allow(classifier).to receive(:classify).and_return([:evaluation])
    end

    context 'when input line is present' do
      it do
        expect(decorator.decorate('(eval)', 123)).to eql(
          ['at (eval):123', '(eval):123']
        )
      end
    end

    context 'when input line is absent' do
      it do
        expect(decorator.decorate('(eval)')).to eql(
          ['at (eval)', '(eval)']
        )
      end
    end
  end

  context 'when path is ruby script' do
    before do
      allow(classifier).to receive(:classify).and_return([:ruby_script])
    end

    context 'when input line is present' do
      it do
        expect(decorator.decorate('(-e ruby script)', 123)).to eql(
          ['at (-e ruby script):123', '(-e ruby script):123']
        )
      end
    end

    context 'when input line is absent' do
      it do
        expect(decorator.decorate('(-e ruby script)')).to eql(
          ['at (-e ruby script)', '(-e ruby script)']
        )
      end
    end
  end

  context 'when path is unknown' do
    before do
      allow(classifier).to receive(:classify).and_return(:unknown)
    end

    context 'when input line is present' do
      it do
        expect(decorator.decorate('/abc/def.rb', 123)).to eql(
          ['at /abc/def.rb:123', '/abc/def.rb:123']
        )
      end
    end

    context 'when input line is shorter if shown in relative path' do
      let(:path) { File.expand_path(File.join(Dir.pwd, '../abc/def.rb')) }

      it do
        expect(decorator.decorate(path)).to eql(
          ['at ../abc/def.rb', '../abc/def.rb']
        )
      end
    end

    context 'when input line is shorter if keep current one' do
      let(:path) { File.expand_path(File.join(Dir.pwd, '../' * 30 + '../abc/def.rb')) }

      it do
        expect(decorator.decorate(path)).to eql(
          ['at /abc/def.rb', '/abc/def.rb']
        )
      end
    end

    context 'when input line is absent' do
      it do
        expect(decorator.decorate('/abc/def.rb')).to eql(
          ['at /abc/def.rb', '/abc/def.rb']
        )
      end
    end
  end
end
