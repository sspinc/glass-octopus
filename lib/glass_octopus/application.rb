require "glass_octopus/consumer"
require "glass_octopus/configuration"

module GlassOctopus
  class Application
    attr_reader :config

    def initialize(processor)
      @processor = processor
      @config    = Configuration.new
      @consumer  = nil
      @running   = false
      @done      = false

      yield @config if block_given?
    end

    def run
      return if running?

      @running = true
      @config.freeze

      @consumer = Consumer.new(connection, @processor, self, config.executor)
      @consumer.run
    end

    def shutdown(timeout=nil)
      return if done? || !running?

      @done = true
      timeout ||= config.shutdown_timeout
      @consumer.shutdown(timeout) if @consumer

      nil
    end

    def logger
      config.logger
    end

    def running?
      @running
    end

    def done?
      @done
    end

    private

    def connection
      config.connection_adapter.new(config.consumer_options)
    end
  end
end
