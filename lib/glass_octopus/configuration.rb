require "logger"

module GlassOctopus
  # Configuration for the application.
  #
  # @!attribute [rw] connection_adapter
  #   Connection adapter that connects to the Kafka.
  # @!attribute [rw] logger
  #   A standard library compatible logger for the application. By default it
  #   logs to the STDOUT.
  class Configuration
    attr_accessor :connection_adapter,
                  :logger

    def initialize
      self.logger = Logger.new(STDOUT).tap { |l| l.level = Logger::INFO }
    end

    # Configures a new adapter.
    #
    # When a class is passed as +type+ the class will be instantiated.
    #
    # @example Using a custom adapter class
    #   config.adapter(MyAdapter) do |c|
    #     c.bootstrap_servers = %w[localhost:9092]
    #     c.group_id = "mygroup"
    #     c.topic = "mytopic"
    #   end
    #
    #   class MyAdapter
    #     def initialize
    #       @options = OpenStruct.new
    #       yield @options
    #     end
    #
    #     def fetch_message
    #       @consumer.each do |fetched_message|
    #         message = Message.new(
    #           fetched_message.topic,
    #          fetched_message.partition,
    #          fetched_message.offset,
    #          fetched_message.key,
    #          fetched_message.value
    #        )
    #
    #         yield message
    #       end
    #     end
    #
    #     def connect
    #       # Connect to Kafka...
    #       @consumer = ...
    #       self
    #     end
    #
    #     def close
    #       @consumer.close
    #     end
    #   end
    #
    # @param type [:ruby_kafka, Class] type of the adapter to use
    # @yield a block to conigure the adapter
    # @yieldparam config configuration object
    #
    # @see RubyKafkaAdapter
    def adapter(type, &block)
      self.connection_adapter = build_adapter(type, &block)
    end

    # @api private
    def build_adapter(type, &block)
      case type
      when :ruby_kafka
        require "glass_octopus/connection/ruby_kafka_adapter"
        RubyKafkaAdapter.new(&block)
      when Class
        type.new(&block)
      else
        raise ArgumentError, "Unknown adapter: #{type}"
      end
    end
  end
end
