# frozen_string_literal: true

module RubyJard
  module Commands
    class BaseCommand < Pry::ClassCommand
      def self.help_doc(location)
        help_doc = File.read(File.join(File.dirname(__FILE__), location))
        help_doc = help_doc.split("\n").map { |line| "    #{line}" }.join("\n")
        banner help_doc + "\n"
      end

      def help
        self.class.banner
      end

      # Set up `opts` and `args`, and then call `process`.
      #
      # This method will display help if necessary.
      #
      # @param [Array<String>] args The arguments passed
      # @return [Object] The return value of `process` or VOID_VALUE
      def call(*args)
        setup

        self.opts = slop
        self.args = opts.parse!(args)

        if opts.present?(:help)
          output.puts help
          output.puts "\n"
          void
        else
          process(*normalize_method_args(method(:process), args))
        end
      end
    end
  end
end
