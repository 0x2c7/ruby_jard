# frozen_string_literal: true

RSpec.describe RubyJard::Commands::UpCommand do
  it_behaves_like 'command with times', :up, :up do
    subject(:command_object) { described_class.new }
  end
end
