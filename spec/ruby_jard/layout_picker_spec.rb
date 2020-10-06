# frozen_string_literal: true

RSpec.describe RubyJard::LayoutPicker do
  let(:fallback_layout) { RubyJard::LayoutTemplate.new }
  let(:layouts) { RubyJard::Layouts.new(fallback_layout) }
  let(:layout_1) { RubyJard::LayoutTemplate.new(min_width: 120, min_height: 24) }
  let(:layout_2) { RubyJard::LayoutTemplate.new(min_width: 80, min_height: 24) }
  let(:layout_3) { RubyJard::LayoutTemplate.new(min_width: 40, min_height: 24) }
  let(:layout_4) { RubyJard::LayoutTemplate.new(min_width: 80, min_height: 10) }

  let(:config) { RubyJard::Config.new }
  let(:picker) { described_class.new(width, height, layouts: layouts, config: config) }

  before do
    layouts.add_layout('layout-1', layout_1)
    layouts.add_layout('layout-2', layout_2)
    layouts.add_layout('layout-3', layout_3)
    layouts.add_layout('layout-4', layout_4)
  end

  context 'when no layouts matched' do
    let(:width) { 100 }
    let(:height) { 5 }

    it 'fallbacks to register fallback layout' do
      expect(picker.pick).to eql(fallback_layout)
    end
  end

  context 'when config.layout configuration is set' do
    let(:width) { 150 }
    let(:height) { 30 }

    context 'when the configuration is not valid' do
      before do
        config.layout = 'not-existed-layout'
      end

      it 'fallbacks to register fallback layout' do
        expect(picker.pick).to eq(fallback_layout)
      end
    end

    context 'when the configuration is valid' do
      before do
        config.layout = 'layout-3'
      end

      it 'returns desired layout regardless of other matched layout' do
        expect(picker.pick).to eq(layout_3)
      end
    end
  end

  context 'when multiple layouts matched' do
    let(:width) { 100 }
    let(:height) { 30 }

    it 'returns the first matched layout' do
      expect(picker.pick).to eq(layout_2)
    end
  end

  context 'when a layout matched' do
    let(:width) { 50 }
    let(:height) { 30 }

    it 'returns the matched layout' do
      expect(picker.pick).to eq(layout_3)
    end
  end
end
