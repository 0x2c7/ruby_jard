# frozen_string_literal: true

RSpec.describe RubyJard::Screens::MenuScreen do
  subject(:menu_screen) { described_class.new(layout: layout, config: config) }

  let(:config) { RubyJard::Config.new }
  let(:layout) do
    RubyJard::Layout.new(
      width: 118, height: 2,
      box_width: 120, box_height: 3, box_x: 0, box_y: 0, x: 0, y: 0,
      template: RubyJard::ScreenTemplate.new
    )
  end

  context 'with default menu screen' do
    it 'displays default filter and keybindings' do
      menu_screen.build
      expect(menu_screen.rows).to match_rows(<<~SPANS)
        Filter (F2): Application                                   Step (F7)   Step Out (Shift+F7)   Next (F8)   Continue (F9)
      SPANS
    end
  end

  context 'when filters are set' do
    it 'displays filters' do
      config.filter_included = ['rails']
      config.filter_excluded = ['spec*', 'some_thing*']

      menu_screen.build
      expect(menu_screen.rows).to match_rows(<<~SPANS)
        Filter (F2): Application +rails -spec* -some_thing*        Step (F7)   Step Out (Shift+F7)   Next (F8)   Continue (F9)
      SPANS
    end
  end

  context 'when default key bindings are changed' do
    it 'displays corresponding key bindings' do
      config.key_bindings = {
        RubyJard::Keys::CTRL_N        => 'jard filter switch',
        RubyJard::Keys::META_L        => 'list',
        RubyJard::Keys::CTRL_F1       => 'up',
        RubyJard::Keys::CTRL_SHIFT_F1 => 'down',
        RubyJard::Keys::META_D        => 'step',
        RubyJard::Keys::META_O        => 'step-out',
        RubyJard::Keys::CTRL_META_N   => 'next',
        RubyJard::Keys::META_F1       => 'continue',
        RubyJard::Keys::META_SHIFT_F1 => 'continue',
        RubyJard::Keys::CTRL_C        => 'interrupt'
      }

      menu_screen.build
      expect(menu_screen.rows).to match_rows(<<~SPANS)
        Filter (Ctrl+N): Application               Step (Meta+D)   Step Out (Meta+O)   Next (Ctrl+Meta+N)   Continue (Meta+F1)
      SPANS
    end
  end

  context 'when an command does not have a corresponding key binding' do
    it 'displays excludes their labels' do
      config.key_bindings = {
        RubyJard::Keys::META_D        => 'step',
        RubyJard::Keys::META_O        => 'step-out',
        RubyJard::Keys::CTRL_META_N   => 'next'
      }

      menu_screen.build
      expect(menu_screen.rows).to match_rows(<<~SPANS)
        Filter: Application                                             Step (Meta+D)   Step Out (Meta+O)   Next (Ctrl+Meta+N)
      SPANS
    end
  end
end
