# frozen_string_literal: true

RSpec.describe RubyJard::Reflection do
  context 'with #call_instance_variables' do
    context 'with nil' do
      it 'returns empty array' do
        expect(described_class.call_instance_variables(nil)).to eq([])
      end
    end

    context 'with an instance of a class' do
      let(:klass) do
        Class.new do
          def initialize
            @a = 1
            @b = 2
          end
        end
      end

      it 'returns correct list of instance variables' do
        expect(described_class.call_instance_variables(klass.new)).to eq([:@a, :@b])
      end
    end

    context 'with a class' do
      let(:klass) do
        Class.new do
          @a = 1
          @b = 2
        end
      end

      it 'returns correct list of class variables' do
        expect(described_class.call_instance_variables(klass)).to eq([:@a, :@b])
      end
    end

    context 'with an instance of a class that overrided instance_variables' do
      let(:klass) do
        Class.new do
          def initialize
            @a = 1
            @b = 1
          end

          def instance_variables
            :ahihi
          end
        end
      end

      it 'returns correct list of instance variables' do
        expect(klass.new.instance_variables).to eq(:ahihi)
        expect(described_class.call_instance_variables(klass.new)).to eq([:@a, :@b])
      end
    end

    context 'with an a class that overrided instance_variables' do
      let(:klass) do
        Class.new do
          @a = 1
          @b = 1

          def self.instance_variables
            :ahihi
          end
        end
      end

      it 'returns correct list of instance variables' do
        expect(klass.instance_variables).to eq(:ahihi)
        expect(described_class.call_instance_variables(klass)).to eq([:@a, :@b])
      end
    end

    context 'with BasicObject class' do
      it 'returns correct list of class variables' do
        expect(described_class.call_instance_variables(BasicObject)).to eq([])
      end
    end

    context 'with an instance of BasicObject class' do
      let(:klass) do
        Class.new(BasicObject) do
          def initialize
            @a = 1
            @b = 1
          end
        end
      end

      it 'returns correct list of class variables' do
        expect(described_class.call_instance_variables(klass.new)).to eq([:@a, :@b])
        expect { klass.new.instance_variables }.to raise_error(NoMethodError)
      end
    end
  end

  context 'with #call_instance_variable_get' do
    context 'with nil' do
      it 'returns nil' do
        expect(described_class.call_instance_variable_get(nil, :@something)).to eq(nil)
      end
    end

    context 'with an instance of a class' do
      let(:klass) do
        Class.new do
          def initialize
            @a = 1
            @b = 2
          end
        end
      end

      it 'returns desired instance variable' do
        expect(described_class.call_instance_variable_get(klass.new, :@a)).to eq(1)
        expect(described_class.call_instance_variable_get(klass.new, :@b)).to eq(2)
        expect(described_class.call_instance_variable_get(klass.new, :@c)).to eq(nil)
      end
    end

    context 'with a class' do
      let(:klass) do
        Class.new do
          @a = 1
          @b = 2
        end
      end

      it 'returns desired class variable' do
        expect(described_class.call_instance_variable_get(klass, :@a)).to eq(1)
        expect(described_class.call_instance_variable_get(klass, :@b)).to eq(2)
        expect(described_class.call_instance_variable_get(klass, :@c)).to eq(nil)
      end
    end

    context 'with an instance of a class that overrided instance_variable_get' do
      let(:klass) do
        Class.new do
          def initialize
            @a = 1
            @b = 2
          end

          def instance_variable_get(*_args)
            :ahihi
          end
        end
      end

      it 'returns correct instance variable' do
        expect(klass.new.instance_variable_get(:@a)).to eq(:ahihi)
        expect(described_class.call_instance_variable_get(klass.new, :@a)).to eq(1)
        expect(described_class.call_instance_variable_get(klass.new, :@b)).to eq(2)
        expect(described_class.call_instance_variable_get(klass.new, :@c)).to eq(nil)
      end
    end

    context 'with an a class that overrided instance_variable_get' do
      let(:klass) do
        Class.new do
          @a = 1
          @b = 2

          def self.instance_variable_get(*_args)
            :ahihi
          end
        end
      end

      it 'returns correct instance variable' do
        expect(klass.instance_variable_get(:@a)).to eq(:ahihi)
        expect(described_class.call_instance_variable_get(klass, :@a)).to eq(1)
        expect(described_class.call_instance_variable_get(klass, :@b)).to eq(2)
        expect(described_class.call_instance_variable_get(klass, :@c)).to eq(nil)
      end
    end

    context 'with an instance of BasicObject class' do
      let(:klass) do
        Class.new(BasicObject) do
          def initialize
            @a = 1
            @b = 2
          end
        end
      end

      it 'returns correct instance variable' do
        expect { klass.new.instance_variable_get(:@a) }.to raise_error(NoMethodError)
        expect(described_class.call_instance_variable_get(klass.new, :@a)).to eq(1)
        expect(described_class.call_instance_variable_get(klass.new, :@b)).to eq(2)
        expect(described_class.call_instance_variable_get(klass.new, :@c)).to eq(nil)
      end
    end
  end

  context 'with #call_inspect' do
    context 'with an instance of a class' do
      let(:klass) do
        Class.new do
          def initialize
            @a = 1
            @b = 2
          end
        end
      end

      it 'returns desired inspection' do
        a = klass.new
        expect(described_class.call_inspect(a)).to eq(a.inspect)
        expect(described_class.call_inspect(a)).to match(
          /#<#<Class:0x[0-9a-z]+>:0x[0-9a-z]+ @a=1, @b=2>/i
        )
      end
    end

    context 'with some built-in classes' do
      it 'returns desired inspection' do
        expect(described_class.call_inspect(Object)).to eq('Object')
        expect(described_class.call_inspect(nil.class)).to eq('NilClass')
        expect(described_class.call_inspect(RubyJard)).to eq('RubyJard')
      end
    end

    context 'with a class' do
      let(:klass) do
        Class.new do
          @a = 1
          @b = 2
        end
      end

      it 'returns desired class inspection' do
        expect(described_class.call_inspect(klass)).to eq(klass.inspect)
        expect(described_class.call_inspect(klass)).to match(
          /#<Class:0x[0-9a-z]+>/i
        )
      end
    end

    context 'with an instance of a class that overrided inspect' do
      let(:klass) do
        Class.new do
          def initialize
            @a = 1
            @b = 2
          end

          def inspect
            'Ahihi class'
          end
        end
      end

      it 'returns original inspection' do
        expect(klass.new.inspect).to eq('Ahihi class')
        expect(described_class.call_inspect(klass.new)).to match(
          /#<#<Class:0x[0-9a-z]+>:0x[0-9a-z]+ @a=1, @b=2>/i
        )
      end
    end

    context 'with an a class that overrided inspect' do
      let(:klass) do
        Class.new do
          @a = 1
          @b = 2

          def self.inspect(*_args)
            'Ahihi class'
          end
        end
      end

      it 'returns correct inspection' do
        expect(klass.inspect).to eq('Ahihi class')
        expect(described_class.call_inspect(klass)).to match(
          /#<Class:0x[0-9a-z]+>/i
        )
      end
    end

    context 'with an instance of BasicObject class' do
      let(:klass) do
        Class.new(BasicObject) do
          def initialize
            @a = 1
            @b = 2
          end
        end
      end

      it 'returns correct inspection' do
        expect { klass.new.inspection(:@a) }.to raise_error(NoMethodError)
        expect(described_class.call_inspect(klass.new)).to match(
          /#<#<Class:0x[0-9a-z]+>:0x[0-9a-z]+ @a=1, @b=2>/i
        )
      end
    end
  end

  context 'with #call_to_s' do
    context 'with an instance of a class' do
      let(:klass) do
        Class.new do
          def initialize
            @a = 1
            @b = 2
          end
        end
      end

      it 'returns desired string' do
        a = klass.new
        expect(described_class.call_to_s(a)).to eq(a.to_s)
        expect(described_class.call_to_s(a)).to match(
          /#<#<Class:0x[0-9a-z]+>:0x[0-9a-z]+>/i
        )
      end
    end

    context 'with some built-in classes' do
      it 'returns desired string' do
        expect(described_class.call_to_s(Object)).to eq('Object')
        expect(described_class.call_to_s(nil.class)).to eq('NilClass')
        expect(described_class.call_to_s(RubyJard)).to eq('RubyJard')
        expect(described_class.call_to_s(Pathname.pwd)).to match(/#<Pathname:0x[0-9a-z]+>/i)
        expect(described_class.call_to_s(Pathname.pwd)).not_to eq(Pathname.pwd.to_s)
      end
    end

    context 'with a class' do
      let(:klass) do
        Class.new do
          @a = 1
          @b = 2
        end
      end

      it 'returns desired class string' do
        expect(described_class.call_to_s(klass)).to eq(klass.to_s)
        expect(described_class.call_to_s(klass)).to match(
          /#<Class:0x[0-9a-z]+>/i
        )
      end
    end

    context 'with an instance of a class that overrided to_s' do
      let(:klass) do
        Class.new do
          def initialize
            @a = 1
            @b = 2
          end

          def to_s
            'Ahihi class'
          end
        end
      end

      it 'returns original inspection' do
        expect(klass.new.to_s).to eq('Ahihi class')
        expect(described_class.call_to_s(klass.new)).to match(
          /#<#<Class:0x[0-9a-z]+>:0x[0-9a-z]+>/i
        )
      end
    end

    context 'with an a class that overrided to_s' do
      let(:klass) do
        Class.new do
          @a = 1
          @b = 2

          def self.to_s(*_args)
            'Ahihi class'
          end
        end
      end

      it 'returns correct instance variable' do
        expect(klass.to_s).to eq('Ahihi class')
        expect(described_class.call_to_s(klass)).to match(
          /#<Class:0x[0-9a-z]+>/i
        )
      end
    end

    context 'with an instance of BasicObject class' do
      let(:klass) do
        Class.new(BasicObject) do
          def initialize
            @a = 1
            @b = 2
          end
        end
      end

      it 'returns correct string' do
        expect { klass.new.to_s }.to raise_error(NoMethodError)
        expect(described_class.call_to_s(klass.new)).to match(
          /#<#<Class:0x[0-9a-z]+>:0x[0-9a-z]+>/i
        )
      end
    end
  end

  context 'with #call_is_a?' do
    context 'with an instance of a class' do
      let(:klass) do
        Class.new {}
      end

      it 'returns correct answer' do
        expect(described_class.call_is_a?(klass.new, klass)).to eq(true)
        expect(described_class.call_is_a?(klass.new, Object)).to eq(true)
        expect(described_class.call_is_a?(klass.class, Class)).to eq(true)
        expect(described_class.call_is_a?(klass, klass)).to eq(false)
      end
    end

    context 'with some built-in classes' do
      it 'returns desired answer' do
        expect(described_class.call_is_a?(Object, Class)).to eq(true)
        expect(described_class.call_is_a?(Object, Module)).to eq(true)
        expect(described_class.call_is_a?(Object, BasicObject)).to eq(true)
        expect(described_class.call_is_a?(Object, StandardError)).to eq(false)
        expect(described_class.call_is_a?(nil, NilClass)).to eq(true)
        expect(described_class.call_is_a?(nil, Class)).to eq(false)
        expect(described_class.call_is_a?(RubyJard, Module)).to eq(true)
        expect(described_class.call_is_a?([], Array)).to eq(true)
        expect(described_class.call_is_a?([], String)).to eq(false)
      end
    end

    context 'with an instance of a class that overrided is_a?' do
      let(:klass) do
        Class.new do
          def is_a?(*_args)
            false
          end
        end
      end

      it 'returns original inspection' do
        expect(klass.new.is_a?(klass)).to eq(false)
        expect(described_class.call_is_a?(klass.new, klass)).to eq(true)
        expect(described_class.call_is_a?(klass.new, Object)).to eq(true)
        expect(described_class.call_is_a?(klass.class, Class)).to eq(true)
        expect(described_class.call_is_a?(klass, klass)).to eq(false)
      end
    end

    context 'with an a class that overrided is_a?' do
      let(:klass) do
        Class.new do
          def self.is_a?(*_args)
            false
          end
        end
      end

      it 'returns correct instance variable' do
        expect(klass.is_a?(Class)).to eq(false)
        expect(described_class.call_is_a?(klass, Object)).to eq(true)
        expect(described_class.call_is_a?(klass.class, Class)).to eq(true)
        expect(described_class.call_is_a?(klass, Module)).to eq(true)
        expect(described_class.call_is_a?(klass, RubyJard)).to eq(false)
      end
    end

    context 'with an instance of BasicObject class' do
      let(:klass) do
        Class.new(BasicObject) do
        end
      end

      it 'returns correct string' do
        expect { klass.new.is_a?(klass) }.to raise_error(NoMethodError)
        expect(described_class.call_is_a?(klass.new, klass)).to eq(true)
        expect(described_class.call_is_a?(klass.new, BasicObject)).to eq(true)
        expect(described_class.call_is_a?(klass.new, Object)).to eq(false)
      end
    end
  end
end
