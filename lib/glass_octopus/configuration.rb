require "ostruct"
require "logger"
require "concurrent"

require "glass_octopus/env"
require "glass_octopus/connection/poseidon_adapter"
require "glass_octopus/bounded_executor"

module GlassOctopus
  class Configuration
    attr_accessor :consumer,
                  :connection_adapter,
                  :executor,
                  :logger,
                  :shutdown_timeout

    def initialize(options={})
      self.class.defaults.merge(options).each do |k,v|
        if respond_to?("#{k}=")
          public_send("#{k}=", v)
        else
          raise ArgumentError, "no such configuration: #{k}"
        end
      end
    end

    def consumer_options
      consumer.to_h
    end

    class << self
      def defaults
        {
          connection_adapter: PoseidonAdapter,
          consumer: OpenStruct.new(default_consumer_options),
          logger: Logger.new(STDOUT).tap { |l| l.level = Logger::INFO },
          executor: default_executor,
          shutdown_timeout: 10,
        }
      end

      def default_executor
        threads = ENV.integer("CONCURRENCY", default: 25)
        BoundedExecutor.new(Concurrent::FixedThreadPool.new(threads), limit: threads)
      end

      def default_consumer_options
        {
          broker_list:    ENV.array("BROKER_LIST"),
          zookeeper_list: ENV.array("ZOOKEEPER_LIST"),
          topic:          ENV["TOPIC"],
          group:          ENV["GROUP"],
        }
      end
    end
  end
end
