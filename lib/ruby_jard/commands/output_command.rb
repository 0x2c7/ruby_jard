# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class OutputCommand < BaseCommand
      group 'RubyJard'
      description 'Show all current program output'
      match 'output'
      help_doc './output_command.doc.txt'

      def initialize(*args)
        super(*args)
        @stdout_storage = RubyJard::Console.stdout_storage
      end

      def process
        sleep 0.25 # Cool down
        pry_instance.pager.open(
          force_open: true,
          pager_start_at_the_end: true,
          prompt: 'Program output'
        ) do |pager|
          @stdout_storage.each do |string|
            string.each do |s|
              pager.write(s)
            end
          end
        end
      end
    end
  end
end
