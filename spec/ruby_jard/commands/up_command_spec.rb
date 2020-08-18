# frozen_string_literal: true

RSpec.describe RubyJard::Commands::UpCommand do
  subject(:command_object) { described_class.new }

  it_behaves_like 'command with times', :up, :up do
  end
end
