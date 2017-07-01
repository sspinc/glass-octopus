require "ostruct"
require "poseidon_cluster"
require "glass_octopus/message"

module GlassOctopus
  # Connection adapter that uses the {https://github.com/bpot/poseidon poseidon
  # gem} to talk to Kafka 0.8.x. Tested with Kafka 0.8.2.
  class PoseidonAdapter
    # @yield configure poseidon in the yielded block
    #   The following configuration values are required:
    #
    #   * +broker_list+: list of Kafka broker addresses
    #   * +zookeeper_list+: list of Zookeeper addresses
    #   * +topic+: name of the topic to subscribe to
    #   * +group+: name of the consumer group
    #
    #   Any other configuration value is passed to
    #   {http://www.rubydoc.info/github/bsm/poseidon_cluster/Poseidon/ConsumerGroup Poseidon::ConsumerGroup}.
    def initialize
      @poseidon_consumer = nil
      @closed = false

      config = OpenStruct.new
      yield config

      @options = config.to_h
      validate_options!
    end

    # Connect to Kafka and Zookeeper, register the consumer group.
    # This also initiates a rebalance in the consumer group.
    def connect
      @poseidon_consumer = create_consumer_group
      self
    end

    # Fetch messages from kafka in a loop.
    # @yield messages read from Kafka
    # @yieldparam message [Message] a Kafka message
    def fetch_message
      @poseidon_consumer.fetch_loop do |partition, messages|
        break if closed?

        messages.each do |message|
          yield build_message(partition, message)
        end

        # Return true to auto-commit offset to Zookeeper
        true
      end
    end

    # @api private
    def close
      @closed = true
      @poseidon_consumer.close if @poseidon_consumer
    end

    # @api private
    def closed?
      @closed
    end

    # @api private
    def create_consumer_group
      options = @options.dup

      Poseidon::ConsumerGroup.new(
        options.delete(:group),
        options.delete(:broker_list),
        options.delete(:zookeeper_list),
        options.delete(:topic),
        { :max_wait_ms => 1000 }.merge(options)
      )
    end

    # @api private
    def build_message(partition, message)
      GlassOctopus::Message.new(message.topic, partition, message.offset, message.key, message.value)
    end

    # @api private
    def validate_options!
      errors = []
      [:group, :broker_list, :zookeeper_list, :topic].each do |key|
        errors << "Missing key: #{key}" unless @options.key?(key)
      end

      raise OptionsInvalid.new(errors) if errors.any?
    end

    class OptionsInvalid < StandardError
      attr_reader :errors

      def initialize(errors)
        super("Invalid consumer options: #{errors.join(", ")}")
        @errors = errors
      end
    end
  end
end
