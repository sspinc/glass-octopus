require "kafka"
require "ostruct"
require "glass_octopus/message"
require "glass_octopus/connection/options_invalid"

module GlassOctopus
  # Connection adapter that uses the {https://github.com/zendesk/ruby-kafka ruby-kafka} gem
  # to talk to Kafka 0.9+.
  #
  # @example
  #   adapter = GlassOctopus::RubyKafkaAdapter.new do |kafka_config|
  #     kafka_config.broker_list = %w[localhost:9092]
  #     kafka_config.topic       = "mytopic"
  #     kafka_config.group       = "mygroup"
  #     kafka_config.kafka       = { logger: Logger.new(STDOUT) }
  #   end
  #
  #   adapter.connect.fetch_message do |message|
  #     p message
  #   end
  #
  class RubyKafkaAdapter
    # A hash that hold the configuration set up in the initializer block.
    # @return [Hash]
    attr_reader :options

    # @yield configure ruby-kafka in the yielded block.
    #
    #   The following configuration values are required:
    #
    #   * +broker_list+: list of Kafka broker addresses
    #   * +topic+: name of the topic to subscribe to
    #   * +group+: name of the consumer group
    #
    #   Optional configuration:
    #
    #   * +kafka+: a hash passed on to Kafka.new
    #   * +consumer+: a hash passed on to kafka.consumer
    #   * +subscription+: a hash passed on to consumer.subscribe
    #
    #   Check the ruby-kafka documentation for driver specific configurations.
    #
    # @raise [OptionsInvalid]
    def initialize
      config = OpenStruct.new
      yield config
      @options = config.to_h
      validate_options

      @kafka = nil
      @consumer = nil
    end

    # Connect to Kafka and join the consumer group.
    # @return [void]
    def connect
      @kafka = connect_to_kafka
      @consumer = create_consumer(@kafka)
      @consumer.subscribe(
        options.fetch(:topic),
        **options.fetch(:subscription, {})
      )

      self
    end

    # Fetch messages from kafka in a loop.
    # @yield messages read from Kafka
    # @yieldparam message [Message] a Kafka message
    def fetch_message
      @consumer.each_message do |fetched_message|
        message = Message.new(
          fetched_message.topic,
          fetched_message.partition,
          fetched_message.offset,
          fetched_message.key,
          fetched_message.value
        )

        yield message
      end
    end

    # @api private
    def close
      @consumer.stop
      @kafka.close
    end

    # @api private
    def connect_to_kafka
      Kafka.new(
        seed_brokers: options.fetch(:broker_list),
        **options.fetch(:kafka, {})
      )
    end

    # @api private
    def create_consumer(kafka)
      kafka.consumer(
        group_id: options.fetch(:group),
        **options.fetch(:consumer, {})
      )
    end

    # @api private
    def validate_options
      errors = []
      [:broker_list, :group, :topic].each do |key|
        errors << "Missing key: #{key}" unless options.key?(key)
      end

      raise OptionsInvalid.new(errors) if errors.any?
    end
  end
end
