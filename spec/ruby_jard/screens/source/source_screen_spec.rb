# frozen_string_literal: true

RSpec.describe 'RubyJard::Screens::SourceScreen' do
  let(:work_dir) { File.join(RSPEC_ROOT, '/ruby_jard/screens/source') }

  context 'with TOPLEVEL_BINDING code' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test1_example.rb:14 ───────────────────────────────┐
        │   5 var_a = 123                                                              │
        │   6 var_b = 'hello world'                                                    │
        │   7 var_c = ['Hello', 1, 2, 3]                                               │
        │   8 variable_d = { test: 1, this: 'Bye', array: nil }                        │
        │   9 variable_e = /Wait, what/i                                               │
        │  10 variable_f = 1.1                                                         │
        │  11 variable_g = 99..100                                                     │
        │  12                                                                          │
        │  13 jard                                                                     │
        │➠ 14 variable_h = 15                                                          │
        │  15                                                                          │
        │  16 jard                                                                     │
        │  17 1.times {}                                                               │
        │  18                                                                          │
        │  19 jard                                                                     │
        │  20 var_a + variable_f + variable_h || 5                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test1_example.rb:16 ───────────────────────────────┐
        │   7 var_c = ['Hello', 1, 2, 3]                                               │
        │   8 variable_d = { test: 1, this: 'Bye', array: nil }                        │
        │   9 variable_e = /Wait, what/i                                               │
        │  10 variable_f = 1.1                                                         │
        │  11 variable_g = 99..100                                                     │
        │  12                                                                          │
        │  13 jard                                                                     │
        │  14 variable_h = 15                                                          │
        │  15                                                                          │
        │➠ 16 jard                                                                     │
        │  17 1.times {}                                                               │
        │  18                                                                          │
        │  19 jard                                                                     │
        │  20 var_a + variable_f + variable_h || 5                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test1_example.rb:17 ───────────────────────────────┐
        │   8 variable_d = { test: 1, this: 'Bye', array: nil }                        │
        │   9 variable_e = /Wait, what/i                                               │
        │  10 variable_f = 1.1                                                         │
        │  11 variable_g = 99..100                                                     │
        │  12                                                                          │
        │  13 jard                                                                     │
        │  14 variable_h = 15                                                          │
        │  15                                                                          │
        │  16 jard                                                                     │
        │➠ 17 1.times {}                                                               │
        │  18                                                                          │
        │  19 jard                                                                     │
        │  20 var_a + variable_f + variable_h || 5                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_4) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test1_example.rb:20 ───────────────────────────────┐
        │  11 variable_g = 99..100                                                     │
        │  12                                                                          │
        │  13 jard                                                                     │
        │  14 variable_h = 15                                                          │
        │  15                                                                          │
        │  16 jard                                                                     │
        │  17 1.times {}                                                               │
        │  18                                                                          │
        │  19 jard                                                                     │
        │➠ 20 var_a + variable_f + variable_h || 5                                     │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/test1_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
      test.send_keys('next', 'Enter')
      expect(test.screen_content).to match_screen(expected_output_2)
      test.send_keys('next', 'Enter')
      expect(test.screen_content).to match_screen(expected_output_3)
      test.send_keys('continue', 'Enter')
      expect(test.screen_content).to match_screen(expected_output_4)
    ensure
      test.stop
    end
  end

  context 'with instance method' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test2_example.rb:23 ───────────────────────────────┐
        │  14   def calculate(n)                                                       │
        │  15     raise 'Exceeded support max' if n > MAX_SUPPORTED                    │
        │  16                                                                          │
        │  17     return @a if n == 1                                                  │
        │  18     return @b if n == 2                                                  │
        │  19                                                                          │
        │  20     (3..n).each do |index|                                               │
        │  21       puts index                                                         │
        │  22       jard                                                               │
        │➠ 23       k = @a + @b                                                        │
        │  24       @a = @b                                                            │
        │  25       @b = k                                                             │
        │  26     end                                                                  │
        │  27                                                                          │
        │  28     @b                                                                   │
        │  29   end                                                                    │
        │  30 end                                                                      │
        │  31                                                                          │
        │  32 Fibonaci.new.calculate(50)                                               │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/test2_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output)
      test.send_keys('continue', 'Enter')
      expect(test.screen_content).to match_screen(expected_output)
      test.send_keys('continue', 'Enter')
      expect(test.screen_content).to match_screen(expected_output)
      test.send_keys('continue', 'Enter')
      expect(test.screen_content).to match_screen(expected_output)
    ensure
      test.stop
    end
  end

  context 'with nested method' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test4_example.rb:13 ───────────────────────────────┐
        │   4                                                                          │
        │   5 class DummyCalculator                                                    │
        │   6   def calculate(n)                                                       │
        │   7     10.times do |index_a|                                                │
        │   8       a = 10                                                             │
        │   9       5.times do |index_b|                                               │
        │  10         b = 'This is sparta'                                             │
        │  11         1.times do |index_c|                                             │
        │  12           jard                                                           │
        │➠ 13           c = n + index_a + index_b + index_c                            │
        │  14         end                                                              │
        │  15       end                                                                │
        │  16     end                                                                  │
        │  17   end                                                                    │
        │  18 end                                                                      │
        │  19                                                                          │
        │  20 DummyCalculator.new.calculate(10)                                        │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/test4_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output)
    ensure
      test.stop
    end
  end

  context 'with jard putting at the beginning of file, as well as at the end of file' do
    let(:expected_output) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test6_example.rb:2 ────────────────────────────────┐
        │   1 require 'ruby_jard'; jard                                                │
        │➠  2 123                                                                      │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/test6_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output)
    ensure
      test.stop
    end
  end

  context 'with code evaluation' do
    let(:expected_output_1) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test7_example.rb:21 ───────────────────────────────┐
        │  12     c = a + b                                                            │
        │  13     c * 3                                                                │
        │  14   end                                                                    │
        │  15 CODE                                                                     │
        │  16                                                                          │
        │  17 eval(code1)                                                              │
        │  18 eval(*code2)                                                             │
        │  19                                                                          │
        │  20 jard                                                                     │
        │➠ 21 test1(1, 2)                                                              │
        │  22 test2(3, 4)                                                              │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_2) do
      <<~EXPECTED
        ┌ Source  (eval):2 ────────────────────────────────────────────────────────────┐
        │This section is anonymous!                                                    │
        │Maybe it is dynamically evaluated, or called via ruby-e, without file informat│
        │ion.                                                                          │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    let(:expected_output_3) do
      <<~EXPECTED
        ┌ Source  ../../../examples/test7_example.rb:12 ───────────────────────────────┐
        │   3 code1 = <<~CODE                                                          │
        │   4   def test1(a, b)                                                        │
        │   5     c = a + b                                                            │
        │   6     c * 2                                                                │
        │   7   end                                                                    │
        │   8 CODE                                                                     │
        │   9                                                                          │
        │  10 code2 = <<~CODE, nil, __FILE__, __LINE__ + 1                             │
        │  11   def test2(a, b)                                                        │
        │➠ 12     c = a + b                                                            │
        │  13     c * 3                                                                │
        │  14   end                                                                    │
        │  15 CODE                                                                     │
        │  16                                                                          │
        │  17 eval(code1)                                                              │
        │  18 eval(*code2)                                                             │
        │  19                                                                          │
        │  20 jard                                                                     │
        │  21 test1(1, 2)                                                              │
        └──────────────────────────────────────────────────────────────────────────────┘
      EXPECTED
    end

    it 'displays correct line' do
      test = JardIntegrationTest.new(work_dir, "bundle exec ruby #{RSPEC_ROOT}/examples/test7_example.rb")
      test.start
      expect(test.screen_content).to match_screen(expected_output_1)
      test.send_keys('step', 'Enter')
      expect(test.screen_content).to match_screen(expected_output_2)
      test.send_keys('step-out', 'Enter')
      test.send_keys('step', 'Enter')
      expect(test.screen_content).to match_screen(expected_output_3)
    ensure
      test.stop
    end
  end
end
