# frozen_string_literal: true

RSpec.describe RubyJard::Config do
  subject(:config) { described_class.new }

  it 'initializes default configurations' do
    expect(config.filter_version).to eq(0)
    expect(config.filter).to eq(:application)
    expect(config.filter_included).to eq([])
    expect(config.filter_excluded).to eq([])

    expect(config.color_scheme).to eq('256')
    expect(config.alias_to_debugger).to eq(false)
    expect(config.layout).to eq(nil)
    expect(config.enabled_screens).to match_array(
      %w[source variables backtrace threads menu]
    )
  end

  it 'freezes nested data structure' do
    expect do
      config.filter_included.append(123)
    end.to raise_error(FrozenError)
    expect do
      config.filter_excluded.append(123)
    end.to raise_error(FrozenError)
    expect do
      config.enabled_screens.append(123)
    end.to raise_error(FrozenError)
  end

  describe '#filter=' do
    it 'updates filter' do
      expect { config.filter = :gems }.to change(config, :filter).from(:application).to(:gems)
    end

    it 'increases filter_version' do
      expect { config.filter = :gems }.to change(config, :filter_version).from(0).to(1)
    end
  end

  describe '#filter_included=' do
    it 'updates filter_included' do
      expect { config.filter_included = ['rails'] }.to change(config, :filter_included).from([]).to(['rails'])
    end

    it 'increases filter_version' do
      expect { config.filter_included = ['rails'] }.to change(config, :filter_version).from(0).to(1)
    end

    it 'freezes filter_included afterward' do
      config.filter_included = ['rails']
      expect do
        config.filter_included.append(123)
      end.to raise_error(FrozenError)
    end
  end

  describe '#filter_excluded=' do
    it 'updates filter_excluded' do
      expect { config.filter_excluded = ['rails'] }.to change(config, :filter_excluded).from([]).to(['rails'])
    end

    it 'increases filter_version' do
      expect { config.filter_excluded = ['rails'] }.to change(config, :filter_version).from(0).to(1)
    end

    it 'freezes filter_excluded afterward' do
      config.filter_excluded = ['rails']
      expect do
        config.filter_excluded.append(123)
      end.to raise_error(FrozenError)
    end
  end

  describe '#enabled_screens=' do
    it 'updates enabled_screens' do
      expect { config.enabled_screens = ['source'] }.to change(config, :enabled_screens).to(['source'])
    end

    it 'freezes filter_excluded afterward' do
      config.enabled_screens = ['source']
      expect do
        config.enabled_screens.append(123)
      end.to raise_error(FrozenError)
    end
  end
end
