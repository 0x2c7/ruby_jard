# frozen_string_literal: true

RSpec.describe RubyJard::Commands::StepOutCommand do
  it_behaves_like 'command with times', 'step-out', :step_out do
    subject(:command_object) { described_class.new }
  end
end
