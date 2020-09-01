# frozen_string_literal: true

RSpec.describe RubyJard::Decorators::InspectionDecorator do
  subject(:decorator) { described_class.new }

  context 'when #decorate_singleline' do
    let(:line_limit) { 80 }

    it {
      expect(decorator.decorate_singleline(true, line_limit: line_limit)).to match_spans(<<~SPANS)
        true
      SPANS
    }

    it {
      expect(decorator.decorate_singleline(false, line_limit: line_limit)).to match_spans(<<~SPANS)
        false
      SPANS
    }

    it {
      expect(decorator.decorate_singleline(12_345, line_limit: line_limit)).to match_spans(<<~SPANS)
        12345
      SPANS
    }

    it {
      expect(decorator.decorate_singleline(123.456, line_limit: line_limit)).to match_spans(<<~SPANS)
        123.456
      SPANS
    }

    it {
      expect(decorator.decorate_singleline((123 + 0i), line_limit: line_limit)).to match_spans(<<~SPANS)
        (123+0i)
      SPANS
    }

    it {
      expect(decorator.decorate_singleline(/abcdef.*[a-z0-9]+]/i, line_limit: line_limit)).to match_spans(<<~SPANS)
        /abcdef.*[a-z0-9]+]/i
      SPANS
    }

    it {
      expect(decorator.decorate_singleline(method(:decorator).to_proc, line_limit: line_limit)).to match_spans(<<~SPANS)
        #<Proc:?????????????????? (lambda)>
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          123_345_789_123_345_789_123_345_789_123_345_789_123_345_789_123_345_789_123_345_789_123_345_789_123_345_789,
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        1233457891233457891233457891233457891233457891233457891233457891233457891233457…
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(Object, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        Object
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(:some_thing, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        :some_thing
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(nil, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        nil
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(0..30, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        0..30
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          'abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh',
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        "abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcde…"
      SPANS
    }

    it {
      expect(decorator.decorate_singleline([1, 2, 3], line_limit: line_limit)).to match_spans(<<~SPANS)
        [1, 2, 3]
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          [1, 'Tenet is awesome', 'Inception is better', { a: 1, b: 2 }],
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        [1, "Tenet is awesome", "Inception is better", {:a → 1, :b → 2}]
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          [1, 'Tenet is awesome', 'Inception is better', { a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }],
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        [1, "Tenet is awesome", "Inception is better", {:a → 1, :b → 2, :c → 3, …}]
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          [1, 'Tenet is awesome ' * 100, 'Inception is better ' * 100, { a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }],
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        [1, "Tenet is awesome Tenet is a…", "Inception is better Incepti…", …]
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          [1, { a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }, 'Inception is better ' * 100],
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        [1, {:a → 1, :b → 2, :c → 3, …}, "Inception is better Incepti…"]
      SPANS
    }

    it {
      expect(decorator.decorate_singleline((1..21).to_a, line_limit: line_limit)).to match_spans(<<~SPANS)
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
      SPANS
    }

    it {
      expect(decorator.decorate_singleline((1..100).to_a, line_limit: 80)).to match_spans(<<~SPANS)
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, …]
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          { movies: [{ name: 'Inception', director: 'Nolan' }, { name: 'Interstella', director: 'Nolan' }] },
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        {:movies → [{:name → "Inception", …}, {:name → "Interstella", …}]}
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          { var_a: 1, var_b: 2, var_c: 'longggggggggggggggggggggg', var_d: :this_is_a_really_long_symbol },
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        {:var_a → 1, :var_b → 2, :var_c → "longgggggggggggggggggg…", …}
      SPANS
    }

    it {
      hash = { other_1: 1, other_2: 2 }
      hash[:self] = hash
      expect(
        decorator.decorate_singleline(hash, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        {:other_1 → 1, :other_2 → 2, :self → {:other_1 → 1, …}}
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          { level_1: { level_2: { level_3: { level_4: { level_5: 'core' } } } } },
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        {:level_1 → {:level_2 → {:level_3 → {:level_4 → {…}}}}}
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          {
            level_1_a: { level_2_a: { level_3_a: 'a', level_3_b: 'b' } },
            level_1_b: { level_2_b: { level_3_c: 'c', level_3_d: 'd' } }
          },
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        {:level_1_a → {:level_2_a → {…}}, :level_1_b → {:level_2_b → {…}}}
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          [
            [{ level_1_a: { level_2_a: 'a', level_2_b: 'b' } }],
            [{ level_1_b: { level_2_c: 'c', level_2_d: 'd' } }]
          ],
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        [[{:level_1_a → {…}}], [{:level_1_b → {…}}]]
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          [
            [[1, 2], [3, 4]],
            [[5, 6], [7, 8]]
          ],
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          Struct.new(:name, :director).new('Tenet', 'Christopher Nolan'),
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        #<struct name → "Tenet", director → "Christopher Nolan">
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          Struct.new(:name, :director, :plot).new(
            'Tenet', 'Christopher Nolan',
            'A secret agent embarks on a dangerous, time-bending mission to prevent the start of World War III.'
          ),
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        #<struct name → "Tenet", director → "Christopher Nolan", …>
      SPANS
    }

    it {
      stub_const('FilmStruct', Struct.new(:name, :director, :plot))
      expect(
        decorator.decorate_singleline(
          FilmStruct.new(
            'Tenet', 'Christopher Nolan',
            'A secret agent embarks on a dangerous, time-bending mission to prevent the start of World War III.'
          ),
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        #<struct FilmStruct name → "Tenet", director → "Christopher Nolan", …>
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          OpenStruct.new(name: 'Tenet', director: 'Christopher Nolan'),
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        #<OpenStruct name="Tenet", director="Christopher Nolan">
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(
          OpenStruct.new(
            name: 'Tenet', director: 'Christopher Nolan',
            plot: 'A secret agent embarks on a dangerous, time-bending mission to prevent the start of World War III.'
          ),
          line_limit: line_limit
        )
      ).to match_spans(<<~SPANS)
        #<OpenStruct name="Tenet", director="Christopher Nolan", plot="A secret agent …>
      SPANS
    }

    it {
      a = Object.new
      3.times { |index| a.instance_variable_set("@var_#{index}".to_sym, index) }
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<Object:?????????????????? @var_0 → 0, @var_1 → 1, @var_2 → 2>
      SPANS
    }

    it {
      a = Object.new
      10.times { |index| a.instance_variable_set("@var_#{index}".to_sym, index) }
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<Object:?????????????????? @var_0 → 0, @var_1 → 1, @var_2 → 2, @var_3 → 3, …>
      SPANS
    }

    it {
      a = Object.new
      3.times { |index| a.instance_variable_set("@var_#{index}".to_sym, index.to_s * 30) }
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<Object:?????????????????? @var_0 → "0000000000000000000000…", …>
      SPANS
    }

    it {
      stub_const('ThisIsATestClass', Class.new)
      a = ThisIsATestClass.new
      3.times { |index| a.instance_variable_set("@var_#{index}".to_sym, index.to_s * 30) }
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<ThisIsATestClass:?????????????????? @var_0 → "0000000000000000000000…", …>
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(BasicObject.new, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<BasicObject:??????????????????>
      SPANS
    }

    it {
      stub_const('ThisIsATestClass', Class.new(BasicObject))
      a = ThisIsATestClass.new
      3.times { |index| RubyJard::Reflection.call_instance_variable_set(a, "@var_#{index}".to_sym, index) }
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<ThisIsATestClass:?????????????????? @var_0 → 0, @var_1 → 1, @var_2 → 2>
      SPANS
    }

    it {
      stub_const(
        'ThisIsATestClass',
        Class.new(BasicObject) do
          def inspect
            ::Kernel.raise 'Please do not step on the Minefield'
          end

          def to_s
            ::Kernel.raise 'Please do not step on the Minefield'
          end
        end
      )
      a = ThisIsATestClass.new
      3.times { |index| RubyJard::Reflection.call_instance_variable_set(a, "@var_#{index}".to_sym, index) }
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<ThisIsATestClass:??????????????????>
      SPANS
    }

    it {
      a = Object.new
      b = Object.new
      c = Object.new
      a.instance_variable_set(:@var_b, b)
      b.instance_variable_set(:@var_c, c)
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<Object:?????????????????? @var_b → #<Object:?????????????????? …>>
      SPANS
    }

    it {
      a = Object.new
      b = Object.new
      c = Object.new
      a.instance_variable_set(:@var_b, b)
      a.instance_variable_set(:@var_c, c)
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<Object:?????????????????? @var_b → #<Object:??????????????????>, …>
      SPANS
    }

    it {
      a = Object.new
      b = Object.new
      c = 'ccc'
      a.instance_variable_set(:@var_b, b)
      a.instance_variable_set(:@int_1, 1000)
      b.instance_variable_set(:@var_c, c)
      b.instance_variable_set(:@int_2, 2000)
      expect(
        decorator.decorate_singleline(a, line_limit: 100)
      ).to match_spans(<<~SPANS)
        #<Object:?????????????????? @var_b → #<Object:?????????????????? …>, @int_1 → 1000>
      SPANS
    }

    it {
      a = Object.new
      b = Object.new
      a.instance_variable_set(:@var_1, 1)
      b.instance_variable_set(:@var_2, 2)
      expect(
        decorator.decorate_singleline([a, b], line_limit: 100)
      ).to match_spans(<<~SPANS)
        [#<Object:?????????????????? @var_1 → 1>, #<Object:?????????????????? @var_2 → 2>]
      SPANS
    }

    it {
      a = Object.new
      b = Object.new
      c = Object.new
      a.instance_variable_set(:@var_1, 1)
      b.instance_variable_set(:@var_2, 2)
      c.instance_variable_set(:@var_3, 3)
      expect(
        decorator.decorate_singleline([a, b, c], line_limit: 100)
      ).to match_spans(<<~SPANS)
        [#<Object:?????????????????? …>, #<Object:?????????????????? …>, #<Object:?????????????????? …>]
      SPANS
    }

    it {
      a = [1, 2, 3]
      a << a
      expect(
        decorator.decorate_singleline(a, line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        [1, 2, 3, [1, 2, 3, [1, 2, 3, […]]]]
      SPANS
    }

    it {
      stub_const('J1X', Class.new)
      a = J1X.new
      b = J1X.new
      c = J1X.new
      a.instance_variable_set(:@var_b, b)
      b.instance_variable_set(:@var_c, c)
      c.instance_variable_set(:@var_a, a)
      expect(
        decorator.decorate_singleline(a, line_limit: 100)
      ).to match_spans(<<~SPANS)
        #<J1X:?????????????????? @var_b → #<J1X:?????????????????? @var_c → #<J1X:?????????????????? …>>>
      SPANS
    }

    it {
      stub_const('MyError', Class.new(StandardError))
      expect(
        decorator.decorate_singleline(MyError.new('This is my fault'), line_limit: line_limit)
      ).to match_spans(<<~SPANS)
        #<MyError: This is my fault>
      SPANS
    }

    it {
      expect(
        decorator.decorate_singleline(decorator, line_limit: 150)
      ).to match_spans(<<~SPANS)
        #<RubyJard::Decorators::InspectionDecorator:?????????????????? @array_decorator → #<RubyJard::Decorators::ArrayDecorator:?????????????????? …>, …>
      SPANS
    }
  end
end
