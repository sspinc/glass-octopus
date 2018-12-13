require "glass_octopus/consumer"
require "glass_octopus/configuration"

module GlassOctopus
  # @api private
  class Application
    attr_reader :config, :processor

    def initialize(processor)
      @processor = processor
      @config    = Configuration.new
      @consumer  = nil

      yield @config
    end

    def run
      @consumer = Consumer.new(connection, processor, config.logger)
      @consumer.run
    end

    def shutdown
      @consumer.shutdown if @consumer
      nil
    end

    def connection
      config.connection_adapter.connect
    end
  end
end
