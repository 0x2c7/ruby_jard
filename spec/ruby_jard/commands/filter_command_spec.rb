# frozen_string_literal: true

RSpec.describe RubyJard::Commands::FilterCommand do
  # Let's create a proper command object, with data injected
  subject(:command_object) do
    described_class.new(
      pry_instance: pry_instance, output: output,
      config: config
    )
  end

  let(:output) { StringIO.new }
  let(:pry_instance) { Pry.new(output: output) }
  let(:config) { RubyJard::Config.new }

  before do
    config.filter = :default_filter
  end

  context 'with `filter`' do
    context 'when no filters available' do
      it 'returns empty list of filters' do
        command_object.process_line 'filter'
        expect(output.string).to eql(<<~CMD)

          Filter mode
            default_filter
          Included (0)
          Excluded (0)

          Please type `jard filter --help` for more information

        CMD
      end
    end

    context 'when somes filters are available' do
      before do
        config.filter = :everything
        config.filter_inclusion = ['rails', 'sidekiq', 'active*']
        config.filter_exclusion = ['tests', '~/ruby/**/*.rb']
      end

      it 'returns current filter mode and list of filters' do
        command_object.process_line 'filter'
        expect(output.string).to eql(<<~CMD)

          Filter mode
            everything
          Included (3)
            +rails
            +sidekiq
            +active*
          Excluded (2)
            -tests
            -~/ruby/**/*.rb

          Please type `jard filter --help` for more information

        CMD
      end
    end
  end

  context 'with `filter [mode]`' do
    context 'when mode not found' do
      it 'returns error' do
        expect do
          command_object.process_line 'filter not_found'
        end.to raise_error(Pry::CommandError, /Invalid filter/)
      end
    end

    context 'when mode is application' do
      it 'changes config filter to appliation, and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter application'
          end
        end.to change(config, :filter).from(:default_filter).to(:application)
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end

    context 'when mode is everything' do
      it 'changes config filter to appliation, and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter everything'
          end
        end.to change(config, :filter).from(:default_filter).to(:everything)
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end

    context 'when mode is source_tree' do
      it 'changes config filter to appliation, and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter source_tree'
          end
        end.to change(config, :filter).from(:default_filter).to(:source_tree)
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end

    context 'when mode is gems' do
      it 'changes config filter to appliation, and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter gems'
          end
        end.to change(config, :filter).from(:default_filter).to(:gems)
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end
  end

  context 'with `filter include`' do
    context 'when arguments are missing' do
      it 'returns error' do
        expect do
          command_object.process_line 'filter include'
        end.to raise_error(Pry::CommandError, /Wrong number of arguments/)
      end
    end

    context 'when filter is not added before' do
      it 'adds filter and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter include rails'
          end
        end.to change(config, :filter_inclusion).from([]).to(['rails'])
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end

    context 'when filter is already added' do
      before do
        config.filter_inclusion = ['rails']
      end

      it 'ignores filter and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter include rails'
          end
        end.not_to change(config, :filter_inclusion)
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end

    context 'when filter is already in exclusion' do
      before do
        config.filter_exclusion = ['rails']
      end

      it 'remove filter from exclusion, add to inclusion, and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter include rails'
          end
        end
          .to change(config, :filter_inclusion)
          .from([]).to(['rails'])
          .and change(config, :filter_exclusion)
          .from(['rails']).to([])

        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end
  end

  context 'with `filter exclude`' do
    context 'when arguments are missing' do
      it 'returns error' do
        expect do
          command_object.process_line 'filter exclude'
        end.to raise_error(Pry::CommandError, /Wrong number of arguments/)
      end
    end

    context 'when filter is not added before' do
      it 'adds filter and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter exclude rails'
          end
        end.to change(config, :filter_exclusion).from([]).to(['rails'])
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end

    context 'when filter is already added' do
      before do
        config.filter_exclusion = ['rails']
      end

      it 'ignores filter and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter exclude rails'
          end
        end.not_to change(config, :filter_exclusion)
        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end

    context 'when filter is already in exclusion' do
      before do
        config.filter_inclusion = ['rails']
      end

      it 'remove filter from exclusion, add to inclusion, and dispatch a flow' do
        flow = nil
        expect do
          flow = RubyJard::ControlFlow.listen do
            command_object.process_line 'filter exclude rails'
          end
        end
          .to change(config, :filter_exclusion)
          .from([]).to(['rails'])
          .and change(config, :filter_inclusion)
          .from(['rails']).to([])

        expect(flow).to be_a(::RubyJard::ControlFlow)
        expect(flow.command).to be(:list)
      end
    end
  end
end
