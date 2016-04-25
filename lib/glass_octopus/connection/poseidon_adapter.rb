require "poseidon_cluster"
require "glass_octopus/message"

module GlassOctopus
  class PoseidonAdapter
    def initialize(options={})
      @options = options
      @poseidon_consumer = nil
      @closed = false
      validate_options!
    end

    def fetch_message
      @poseidon_consumer = create_consumer_group
      @poseidon_consumer.fetch_loop do |partition, messages|
        break if closed?

        messages.each do |message|
          yield build_message(partition, message)
        end

        # Return true to auto-commit offset to Zookeeper
        true
      end
    end

    def close
      @closed = true
      @poseidon_consumer.close if @poseidon_consumer
    end

    def closed?
      @closed
    end

    private

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

    def build_message(partition, message)
      GlassOctopus::Message.new(message.topic, partition, message.offset, message.key, message.value)
    end

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
