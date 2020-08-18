# frozen_string_literal: true

RSpec.describe RubyJard::Commands::StepCommand do
  subject(:command_object) { described_class.new }

  it_behaves_like 'command with times', :step, :step do
  end
end
