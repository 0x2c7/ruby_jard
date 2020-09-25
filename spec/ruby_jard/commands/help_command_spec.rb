# frozen_string_literal: true

RSpec.describe RubyJard::Commands::HelpCommand do
  subject(:command_object) do
    described_class.new(
      pry_instance: pry_instance, output: output,
      command_set: Pry.config.commands
    )
  end

  let(:output) { StringIO.new }
  let(:pry_instance) { Pry.new(output: output) }

  context 'without arguments' do
    it 'includes essential information' do
      command_object.process_line 'help'
      expect(output.string).to match(/Just Another Ruby Debugger/)
      expect(output.string).to match(%r{https://rubyjard.org/docs})
      expect(output.string).to match(/step-out/)
      expect(output.string).to match(/continue/)
      expect(output.string).to match(/color-scheme/)
      expect(output.string).to match(/help -a/)
    end
  end

  context 'with -a flag' do
    it 'returns all command' do
      command_object.process_line 'help -a'
      expect(output.string).to match(/Just Another Ruby Debugger/)
      expect(output.string).to match(%r{https://rubyjard.org/docs})
      expect(output.string).to match(/step-out/)
      expect(output.string).to match(/continue/)
      expect(output.string).to match(/amend-line/)
      expect(output.string).to match(/pry-version/)
      expect(output.string).not_to match(/color-scheme/)
      expect(output.string).not_to match(/help -a/)
    end
  end

  context 'with valid search argument' do
    it 'returns help from a particular command' do
      command_object.process_line 'help exit'
      expect(output.string).to match(/Default key binding/)
      expect(output.string).to match(/Exit the execution of the program/)
    end
  end

  context 'with invalid search argument' do
    it 'returns error' do
      expect do
        command_object.process_line 'help do-not-exist'
      end.to raise_error(Pry::CommandError, "No help found for 'do-not-exist'")
    end
  end
end
