# frozen_string_literal: true

RSpec.describe RubyJard::Commands::DownCommand do
  it_behaves_like 'command with times', :down, :down do
    subject(:command_object) { described_class.new }
  end
end
