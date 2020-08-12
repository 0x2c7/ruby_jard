# frozen_string_literal: true

RSpec.describe 'RubyJard::Screens::VariablesScreen' do
  let(:work_dir) { File.join(RSPEC_ROOT, '/ruby_jard/screens/variables') }

  context 'when jard stops at top-level binding' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = main                                                                 │
        │  var_a = 123                                                                 │
        │  var_b = "hello world"                                                       │
        │  var_c (len:4) = ["Hello", 1, 2, 3]                                          │
        │  variable_d (size:3) = {:test=>1, :this=>"Bye", :array=>nil}                 │
        │  variable_e = /Wait, what/i                                                  │
        │  variable_f = 1.1                                                            │
        │  variable_g = 99..100                                                        │
        │• variable_h = nil                                                            │
        │  variable_k = #<StandardError: A random error>                               │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = main                                                                 │
        │  var_a = 123                                                                 │
        │  var_b = "hello world"                                                       │
        │  var_c (len:4) = ["Hello", 1, 2, 3]                                          │
        │  variable_d (size:3) = {:test=>1, :this=>"Bye", :array=>nil}                 │
        │  variable_e = /Wait, what/i                                                  │
        │  variable_f = 1.1                                                            │
        │  variable_g = 99..100                                                        │
        │  variable_h = 15                                                             │
        │  variable_k = #<StandardError: A random error>                               │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = main                                                                 │
        │• var_a = 123                                                                 │
        │  var_b = "hello world"                                                       │
        │  var_c (len:4) = ["Hello", 1, 2, 3]                                          │
        │  variable_d (size:3) = {:test=>1, :this=>"Bye", :array=>nil}                 │
        │  variable_e = /Wait, what/i                                                  │
        │• variable_f = 1.1                                                            │
        │  variable_g = 99..100                                                        │
        │• variable_h = 15                                                             │
        │  variable_k = #<StandardError: A random error>                               │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'captures all variables' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/top_level_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
      test.send_keys('continue', :Enter)
      expect(test.screen_content).to match_screen(expected_output_2)
      test.send_keys('continue', :Enter)
      expect(test.screen_content).to match_screen(expected_output_3)
    ensure
      test.stop
    end
  end

  context 'when jard stops at an instance method' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<Fibonaci:??????????????????>                                       │
        │  index = 3                                                                   │
        │• k = nil                                                                     │
        │  n = 50                                                                      │
        │• @a = 1                                                                      │
        │• @b = 1                                                                      │
        │  @other = 5                                                                  │
        │  MAX_SUPPORTED = 64                                                          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<Fibonaci:??????????????????>                                       │
        │  index = 4                                                                   │
        │• k = nil                                                                     │
        │  n = 50                                                                      │
        │• @a = 1                                                                      │
        │• @b = 2                                                                      │
        │  @other = 5                                                                  │
        │  MAX_SUPPORTED = 64                                                          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<Fibonaci:??????????????????>                                       │
        │  index = 5                                                                   │
        │• k = nil                                                                     │
        │  n = 50                                                                      │
        │• @a = 2                                                                      │
        │• @b = 3                                                                      │
        │  @other = 5                                                                  │
        │  MAX_SUPPORTED = 64                                                          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'captures all variables' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/instance_method_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
      test.send_keys('continue', :Enter)
      expect(test.screen_content).to match_screen(expected_output_2)
      test.send_keys('continue', :Enter)
      expect(test.screen_content).to match_screen(expected_output_3)
    ensure
      test.stop
    end
  end

  context 'when jard stops inside a class method' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = FibonaciCalculator                                                   │
        │• m = 10                                                                      │
        │  n = 10                                                                      │
        │  @root = "testing jard"                                                      │
        │  A_USELESS_CONSTANT = "123"                                                  │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'captures all variables' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/class_method_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output)
    ensure
      test.stop
    end
  end

  context 'when jard stops inside a nested loop' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<DummyCalculator:??????????????????>                                │
        │  a = 10                                                                      │
        │  b = "This is sparta"                                                        │
        │• c = nil                                                                     │
        │• index_a = 0                                                                 │
        │• index_b = 0                                                                 │
        │• index_c = 0                                                                 │
        │• n = 10                                                                      │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'captures all variables' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/nested_loop_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output)
    ensure
      test.stop
    end
  end

  context 'with jard jumping between methods' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<Calculator:??????????????????>                                     │
        │  a = 1                                                                       │
        │  b = 2                                                                       │
        │  c = 3                                                                       │
        │• d = 3                                                                       │
        │• e = nil                                                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<SubCalculator:??????????????????>                                  │
        │• d = 3                                                                       │
        │• d1 = nil                                                                    │
        │  d2 = nil                                                                    │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<SubCalculator:??????????????????>                                  │
        │• d = 3                                                                       │
        │  d1 = 6                                                                      │
        │• d2 = nil                                                                    │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_4) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<Calculator:??????????????????>                                     │
        │  a = 1                                                                       │
        │  b = 2                                                                       │
        │• c = 3                                                                       │
        │  d = 3                                                                       │
        │• e = 12                                                                      │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'captures all variables' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/instance_method_2_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
      test.send_keys('step', :Enter)
      expect(test.screen_content).to match_screen(expected_output_2)
      test.send_keys('next', :Enter)
      expect(test.screen_content).to match_screen(expected_output_3)
      test.send_keys('continue', :Enter)
      expect(test.screen_content).to match_screen(expected_output_4)
    ensure
      test.stop
    end
  end

  context 'when jard steps into a code evaluation' do
    let(:expected_output_1) do
      <<~'EXPECTED'
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = main                                                                 │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = main                                                                 │
        │  a = 1                                                                       │
        │  b = 2                                                                       │
        │  c = nil                                                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~'EXPECTED'
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = main                                                                 │
        │• a = 3                                                                       │
        │• b = 4                                                                       │
        │• c = nil                                                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/evaluation_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
      test.send_keys('step', :Enter)
      expect(test.screen_content).to match_screen(expected_output_2)
      test.send_keys('step-out', :Enter)
      test.send_keys('step', :Enter)
      expect(test.screen_content).to match_screen(expected_output_3)
    ensure
      test.stop
    end
  end

  context 'when jard stops at the end of a method' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<DummyCalculator:??????????????????>                                │
        │  index_c = 0                                                                 │
        │  n = 11                                                                      │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<DummyCalculator:??????????????????>                                │
        │  n = 11                                                                      │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/end_of_method_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
      test.send_keys('continue', :Enter)
      expect(test.screen_content).to match_screen(expected_output_2)
    ensure
      test.stop
    end
  end

  context 'when use jard with ruby -e' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = main                                                                 │
        │  a = nil                                                                     │
        │  b = nil                                                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = main                                                                 │
        │  a = 400                                                                     │
        │  b = nil                                                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      code = <<~CODE
        bundle exec ruby -e \"require 'ruby_jard'\njard\na = 100 + 300\nb = a + 1\"
      CODE
      test = JardIntegrationTest.new(work_dir, code)
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
      test.send_keys('next', :Enter)
      expect(test.screen_content).to match_screen(expected_output_2)
    ensure
      test.stop
    end
  end

  context 'when jumping into an ERB file' do
    let(:expected_output) do
      <<~'EXPECTED'
        ┌ Variables ───────────────────────────────────────────────────────────────────┐
        │  self = #<ProductView::ProductObject:??????????????????>                     │
        │  capitalized_name = "BITCOIN"                                                │
        │• price = 5710                                                                │
        │  _erbout (len:39) = "\n<h1>BITCOIN</h1>\n<ul>\n  \n    \n    <li>"           │
        │  @name = "Bitcoin"                                                           │
        │  @prices (len:2) = [5710, 5810]                                              │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/erb_evaluation.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output)
    ensure
      test.stop
    end
  end
end
