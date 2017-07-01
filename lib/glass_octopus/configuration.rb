require "logger"
require "concurrent"

require "glass_octopus/bounded_executor"

module GlassOctopus
  class Configuration
    attr_accessor :connection_adapter,
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

    class << self
      def defaults
        {
          logger: Logger.new(STDOUT).tap { |l| l.level = Logger::INFO },
          executor: default_executor,
          shutdown_timeout: 10,
        }
      end

      def default_executor
        BoundedExecutor.new(Concurrent::FixedThreadPool.new(25), limit: 25)
      end
    end
  end
end
