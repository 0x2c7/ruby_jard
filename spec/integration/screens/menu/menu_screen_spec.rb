# frozen_string_literal: true

RSpec.describe 'Menu screen', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/screens/menu') }

  context 'with default menu screen' do
    it 'displays default filter and keybindings' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'default_menu.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb",
          width: 120, height: 5
        )
        test.start
        test.assert_screen
      ensure
        test.stop
      end
    end
  end

  context 'with tiny window' do
    it 'prioritizes filter' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'tiny_menu.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb",
          width: 50, height: 10
        )
        test.start
        test.assert_screen
        test.send_keys('jard filter include rails', :Enter)
        test.send_keys('jard filter exclude spec*', :Enter)
        test.send_keys('jard filter exclude some_thing*', :Enter)
        test.assert_screen
      ensure
        test.stop
      end
    end
  end

  context 'when switching filter modes' do
    it 'displays current filter mode and keybindings' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'switch_modes.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb",
          width: 120, height: 5
        )
        test.start
        test.assert_screen
        test.send_keys('jard filter gems', :Enter)
        test.assert_screen
        test.send_keys('jard filter source_tree', :Enter)
        test.assert_screen
        test.send_keys('jard filter everything', :Enter)
        test.assert_screen
        test.send_keys('jard filter application', :Enter)
        test.assert_screen
      ensure
        test.stop
      end
    end
  end

  context 'when include/exclude filters' do
    it 'displays current filter mode, filters and keybindings' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'include_exclude_filters.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb",
          width: 120, height: 5
        )
        test.start
        test.assert_screen
        test.send_keys('jard filter gems', :Enter)
        test.send_keys('jard filter include rails', :Enter)
        test.assert_screen
        test.send_keys('jard filter exclude spec*', :Enter)
        test.assert_screen
        test.send_keys('jard filter include ~/library_a/abc.rb', :Enter)
        test.assert_screen
        test.send_keys('jard filter include test*', :Enter)
        test.assert_screen
        test.send_keys('jard filter exclude rails', :Enter)
        test.assert_screen
        test.send_keys('jard filter clear', :Enter)
        test.assert_screen
      ensure
        test.stop
      end
    end
  end
end
