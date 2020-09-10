# frozen_string_literal: true

require 'uri'

RSpec.describe RubyJard::PathClassifier do
  subject(:classifier) { described_class.new }

  context 'when input path is nil' do
    it 'returns unknown' do
      expect(classifier.classify(nil)).to eq(:unknown)
    end
  end

  context 'when input path is in current dir' do
    let(:dir) { Dir.pwd }

    it 'returns source tree' do
      expect(classifier.classify("#{dir}/test.rb")).to eq(:source_tree)
    end
  end

  context 'when input path is in sub-folder of current dir' do
    let(:dir) { Dir.pwd }

    it 'returns source tree' do
      expect(classifier.classify("#{dir}/abc/test.rb")).to eq(:source_tree)
    end
  end

  context 'when input path is in current dir which is also gem path' do
    let(:dir) { Gem.path.first }

    it 'returns source tree' do
      Dir.chdir(dir) do
        expect(classifier.classify("#{dir}/abc/test.rb")).to eq(:source_tree)
      end
    end
  end

  context 'when input path is in current dir which is also bundler path' do
    let(:dir) { Bundler.bundle_path }

    it 'returns source tree' do
      Dir.chdir(dir) do
        expect(classifier.classify("#{dir}/abc/test.rb")).to eq(:source_tree)
      end
    end
  end

  context 'when input path is a gem from bundler' do
    it 'returns gem, version, and relative path' do
      expect(classifier.classify(RSpec.method(:describe).source_location.first)).to eq(
        [:gem, 'rspec-core', RSpec::Core::Version::STRING, 'lib/rspec/core/dsl.rb']
      )
    end
  end

  context 'when input path is a gem from bundler without version' do
    let(:dir) { Bundler.bundle_path }

    it 'returns gem, version, and relative path' do
      expect(classifier.classify("#{dir}/gems/a_random_gem/abc/def.rb")).to eq(
        [:gem, 'a_random_gem', nil, 'abc/def.rb']
      )
    end
  end

  context 'when input path is a gem' do
    let(:path) do
      command = "#{RbConfig.ruby} -e "\
        "\"require 'jard_merge_sort'; puts JardMergeSort::Merger.instance_method(:merge).source_location[0]\""
      `#{command}`
    end

    it 'returns gem, version, and relative path' do
      expect(classifier.classify(path.strip)).to eq(
        [:gem, 'jard_merge_sort', '0.1.0', 'lib/jard_merge_sort/merger.rb']
      )
    end
  end

  context 'when input path is a gem without version' do
    let(:dir) { Gem.path.first }

    it 'returns gem, version, and relative path' do
      expect(classifier.classify("#{dir}/gems/a_random_gem/abc/def.rb")).to eq(
        [:gem, 'a_random_gem', nil, 'abc/def.rb']
      )
    end
  end

  context 'when input path is a standard lib' do
    it 'returns stdlib, and relative path' do
      expect(classifier.classify(Gem.method(:path).source_location.first)).to eq(
        [:stdlib, 'rubygems', 'rubygems.rb']
      )
    end
  end

  context 'when input path is a standard lib sub folder' do
    it 'returns stdlib, and relative path' do
      expect(classifier.classify(URI::HTTP.method(:build).source_location.first)).to eq(
        [:stdlib, 'uri', 'uri/http.rb']
      )
    end
  end

  context 'when input path is a code evaluation' do
    let(:path) { eval("\"\#\{__FILE__\}\"") }

    it 'returns stdlib, and relative path' do
      expect(classifier.classify(path)).to eq(:evaluation)
    end
  end

  context 'when input path is a -e ruby_script' do
    it 'returns stdlib, and relative path' do
      expect(classifier.classify('-e')).to eq(:ruby_script)
    end
  end

  context 'when input path is a an internal location' do
    it 'returns stdlib, and relative path' do
      expect(classifier.classify('<internal:gc>')).to eq(:internal)
    end
  end

  context 'when input path is in a random place' do
    it 'returns unknown' do
      expect(classifier.classify('/some/place/in/void/abc/test.rb')).to eq(:unknown)
    end
  end

  context 'when input path is a relative path not in current dir' do
    it 'returns unknown' do
      expect(classifier.classify('../abc/test.rb')).to eq(:unknown)
    end
  end
end
