require "test_helper"

require "thread"
require "glass_octopus/connection/ruby_kafka_adapter"

class GlassOctopus::RubyKafkaAdapterTest < Minitest::Test
  TOPIC = "test_topic".freeze
  GROUP = "test_group".freeze
  KAFKA_HOST = "localhost:29092"

  attr_reader :client, :producer

  def teardown
    @client.close if @client
  end

  def test_validate_options
    ex = assert_raises(GlassOctopus::OptionsInvalid) { GlassOctopus::RubyKafkaAdapter.new {} }

    assert_includes ex.errors, "Missing key: broker_list"
    assert_includes ex.errors, "Missing key: group_id"
    assert_includes ex.errors, "Missing key: topic"
  end

  def test_fetch_message_yield_messages
    integration_test!

    send_message("key", "value")
    adapter = create_adapter.connect

    q = Queue.new
    Thread.new { q.pop; adapter.close }

    adapter.fetch_message do |message|
      assert_equal "value", message.value
      assert_equal "key", message.key
      assert_equal TOPIC, message.topic
      assert_equal 0, message.partition
      q << :done
    end
  end

  def send_message(key, value)
    @client ||= Kafka.new(seed_brokers: [KAFKA_HOST])
    @client.deliver_message(value, key: key, topic: TOPIC, partition: 0)
  end

  def create_adapter
    GlassOctopus::RubyKafkaAdapter.new do |config|
      config.broker_list = [KAFKA_HOST]
      config.topic = TOPIC
      config.group_id = GROUP
    end
  end
end

