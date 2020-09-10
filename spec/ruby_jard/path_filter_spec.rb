# frozen_string_literal: true

require 'uri'

def path_filter_test_case_name(test_case, mode)
  name = ["when filter is #{mode}"]
  name << "Included #{test_case[:included].join(', ')}" if !test_case[:included].nil? && !test_case[:included].empty?
  name << "Excluded #{test_case[:excluded].join(', ')}" if !test_case[:excluded].nil? && !test_case[:excluded].empty?
  name << "Path is #{test_case[:path]}"
  name.join('. ')
end

RSpec.describe RubyJard::PathFilter do
  subject(:filter) { described_class.new(config: config, path_classifier: path_classifier) }

  let(:config) { RubyJard::Config.new }
  let(:path_classifier) { RubyJard::PathClassifier.new }

  test_cases = [
    {
      path: File.expand_path('./lib/ruby_jard/row.rb'),
      type: :source_tree,
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: File.expand_path('./lib/ruby_jard/row.rb'),
      type: :source_tree,
      excluded: ['./lib/ruby_jard/*'],
      modes: { everything: false, gems: false, application: false, source_tree: false }
    },
    {
      path: File.expand_path('./lib/ruby_jard/row.rb'),
      type: :source_tree,
      excluded: ['./lib/ruby_jard/row2.rb'],
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: File.expand_path('./lib/ruby_jard/row.rb'),
      type: :source_tree,
      excluded: [File.expand_path('./lib/ruby_jard/*')],
      modes: { everything: false, gems: false, application: false, source_tree: false }
    },
    {
      path: File.expand_path('./lib/ruby_jard/row.rb'),
      type: :source_tree,
      excluded: [File.expand_path('./lib/ruby_jard/row2.rb')],
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: File.expand_path('./lib/ruby_jard/row.rb'),
      type: :source_tree,
      excluded: ['./lib/.././lib/ruby_jard/row.rb'],
      modes: { everything: false, gems: false, application: false, source_tree: false }
    },
    {
      path: File.expand_path('/random_place/lib/ruby_jard/row.rb'),
      type: :unknown,
      modes: { everything: true, gems: true, application: true, source_tree: false }
    },
    {
      path: File.expand_path('/random_place/lib/ruby_jard/row.rb'),
      type: :unknown,
      included: ['/random_place/*'],
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: File.expand_path('/random_place/lib/ruby_jard/row.rb'),
      type: :unknown,
      excluded: ['/random_place/*'],
      modes: { everything: false, gems: false, application: false, source_tree: false }
    },
    {
      path: File.expand_path('/random_place/lib/ruby_jard/row.rb'),
      type: :unknown,
      included: ['/random_place/lib/ruby_jard/row2.rb'],
      modes: { everything: true, gems: true, application: true, source_tree: false }
    },
    {
      path: RSpec.method(:describe).source_location[0],
      type: :gem,
      info: ['rspec-core', RSpec::Core::Version::STRING, 'lib/rspec/core/dsl.rb'],
      modes: { everything: true, gems: true, application: false, source_tree: false }
    },
    {
      path: RSpec.method(:describe).source_location[0],
      type: :gem,
      included: ['rspec'],
      info: ['rspec-core', RSpec::Core::Version::STRING, 'lib/rspec/core/dsl.rb'],
      modes: { everything: true, gems: true, application: false, source_tree: false }
    },
    {
      path: RSpec.method(:describe).source_location[0],
      type: :gem,
      included: ['rspec-core'],
      info: ['rspec-core', RSpec::Core::Version::STRING, 'lib/rspec/core/dsl.rb'],
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: RSpec.method(:describe).source_location[0],
      type: :gem,
      included: ['rspec*'],
      info: ['rspec-core', RSpec::Core::Version::STRING, 'lib/rspec/core/dsl.rb'],
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: RSpec.method(:describe).source_location[0],
      type: :gem,
      included: ['sidekiq*'],
      info: ['rspec-core', RSpec::Core::Version::STRING, 'lib/rspec/core/dsl.rb'],
      modes: { everything: true, gems: true, application: false, source_tree: false }
    },
    {
      path: RSpec.method(:describe).source_location[0],
      type: :gem,
      excluded: ['rspec-core'],
      info: ['rspec-core', RSpec::Core::Version::STRING, 'lib/rspec/core/dsl.rb'],
      modes: { everything: false, gems: false, application: false, source_tree: false }
    },
    {
      path: RSpec.method(:describe).source_location[0],
      type: :gem,
      excluded: ['rspec-*'],
      info: ['rspec-core', RSpec::Core::Version::STRING, 'lib/rspec/core/dsl.rb'],
      modes: { everything: false, gems: false, application: false, source_tree: false }
    },
    {
      path: Gem.method(:path).source_location.first,
      type: :stdlib,
      info: ['rubygems', 'rubygems.rb'],
      modes: { everything: true, gems: false, application: false, source_tree: false }
    },
    {
      path: Gem.method(:path).source_location.first,
      type: :stdlib,
      included: ['ruby*'],
      info: ['rubygems', 'rubygems.rb'],
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: Gem.method(:path).source_location.first,
      type: :stdlib,
      included: ['rubygems'],
      info: ['rubygems', 'rubygems.rb'],
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: Gem.method(:path).source_location.first,
      type: :stdlib,
      included: ['sidekiq'],
      info: ['rubygems', 'rubygems.rb'],
      modes: { everything: true, gems: false, application: false, source_tree: false }
    },
    {
      path: Gem.method(:path).source_location.first,
      type: :stdlib,
      included: ['sidekiq', 'ruby*'],
      info: ['rubygems', 'rubygems.rb'],
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: Gem.method(:path).source_location.first,
      type: :stdlib,
      excluded: ['sidekiq'],
      info: ['rubygems', 'rubygems.rb'],
      modes: { everything: true, gems: false, application: false, source_tree: false }
    },
    {
      path: Gem.method(:path).source_location.first,
      type: :stdlib,
      excluded: ['rubygems'],
      info: ['rubygems', 'rubygems.rb'],
      modes: { everything: false, gems: false, application: false, source_tree: false }
    },
    {
      path: '<internal:gc>',
      type: :internal,
      modes: { everything: true, gems: false, application: false, source_tree: false }
    },
    {
      path: '<internal:gc>',
      type: :internal,
      included: ['<internal:*>'],
      modes: { everything: true, gems: false, application: false, source_tree: false }
    },
    {
      path: '<internal:gc>',
      type: :internal,
      included: ['<internal:pack>'],
      modes: { everything: true, gems: false, application: false, source_tree: false }
    },
    {
      path: '<internal:gc>',
      type: :internal,
      excluded: ['internal:*'],
      modes: { everything: true, gems: false, application: false, source_tree: false }
    },
    {
      path: '-e',
      type: :ruby_script,
      modes: { everything: true, gems: true, application: true, source_tree: true }
    },
    {
      path: '(eval)',
      type: :evaluation,
      modes: { everything: true, gems: true, application: false, source_tree: false }
    }
  ]

  test_cases.each do |test_case|
    test_case[:modes].each do |mode, result|
      context path_filter_test_case_name(test_case, mode) do
        before do
          config.filter = mode
          config.filter_included = test_case[:included] || []
          config.filter_excluded = test_case[:excluded] || []

          allow(path_classifier).to receive(:classify).and_return([test_case[:type], *test_case[:info]])
        end

        it "returns #{result}" do
          expect(filter.match?(test_case[:path])).to eq(result)
        end
      end
    end
  end
end
