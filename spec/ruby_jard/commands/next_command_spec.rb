# frozen_string_literal: true

RSpec.describe RubyJard::Commands::NextCommand do
  it_behaves_like 'command with times', :next, :next do
    subject(:command_object) { described_class.new }
  end
end
