require "logger"
require "concurrent"

require "glass_octopus/bounded_executor"

module GlassOctopus
  # Configuration for the application.
  #
  # @!attribute [rw] connection_adapter
  #   Connection adapter that connects to the Kafka.
  # @!attribute [rw] executor
  #   A thread pool executor to process messages concurrently. Defaults to
  #   a {BoundedExecutor} with 25 threads.
  # @!attribute [rw] logger
  #   A standard library compatible logger for the application. By default it
  #   logs to the STDOUT.
  # @!attribute [rw] shutdown_timeout
  #   Number of seconds to wait for the processing to finish before shutting down.
  class Configuration
    attr_accessor :connection_adapter,
                  :executor,
                  :logger,
                  :shutdown_timeout

    def initialize
      self.logger = Logger.new(STDOUT).tap { |l| l.level = Logger::INFO }
      self.executor = default_executor
      self.shutdown_timeout = 10
    end

    # @api private
    def default_executor
      BoundedExecutor.new(Concurrent::FixedThreadPool.new(25), limit: 25)
    end
  end
end
