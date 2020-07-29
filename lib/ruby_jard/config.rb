# frozen_string_literal: true

module RubyJard
  ##
  # Another reinvent-the-wheel configuration
  class Config
    class << self
      def smart_load
        config = RubyJard::Config.new

        path = File.expand_path(File.join(Dir.pwd, CONFIG_FILE_NAME))
        load_config(config, path) if File.exist?(path)

        path = File.expand_path(File.join('~/', CONFIG_FILE_NAME))
        load_config(config, path) if File.exist?(path)

        config
      rescue StandardError => e
        # Fallback to default setting
        STDOUT.puts "Fail to load jard configurations at #{path}. Error: #{e}"
        RubyJard::Config.new
      end

      private

      def load_config(config, path)
        config_content = File.read(path)
        config.instance_eval(config_content)

        config
      end
    end

    attr_reader :color_scheme
    attr_writer :color_scheme

    CONFIG_FILE_NAME = '.jardrc'
    DEFAULTS = [
      DEFAULT_COLOR_SCHEME = '256'
    ].freeze

    def initialize
      @color_scheme = DEFAULT_COLOR_SCHEME
    end

    def config
      self
    end
  end
end
