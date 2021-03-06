# frozen_string_literal: true

RSpec.describe 'Pager tests', integration: true do
  let(:work_dir) { File.join(RSPEC_ROOT, '/integration/commands') }

  context 'when output directly into screen' do
    it 'display pager perfectly' do
      begin
        test = JardIntegrationTest.new(
          self, work_dir,
          'pager.expected',
          "bundle exec ruby #{RSPEC_ROOT}/examples/pager_example.rb"
        )
        test.start
        test.assert_screen

        test.send_keys('hash_a', :Enter)
        test.assert_screen
        test.send_keys('continue', :Enter)

        test.send_keys('hash_b', :Enter)
        test.assert_screen
        test.send_keys('continue', :Enter)

        test.send_keys('hash_c', :Enter)
        test.assert_screen
        test.send_keys('continue', :Enter)

        test.send_keys('hash_d', :Enter)
        test.assert_screen
        test.send_keys('continue', :Enter)

        test.send_keys('hash_e', :Enter)
        test.assert_screen
        test.send_keys('G')
        test.assert_screen
        test.send_keys('gg')
        test.assert_screen
        test.send_keys('/variable_17', :Enter)
        test.assert_screen
        test.send_keys('q')
        test.assert_screen
      ensure
        test.stop
      end
    end
  end
end
