require "test_helper"
require "support/null_logger"

require "thread"
require "glass_octopus/connection/poseidon_adapter.rb"

class GlassOctopus::PoseidonAdapterTest < Minitest::Test
  TEST_TOPIC = "test_topic".freeze
  TEST_GROUP = "test_group".freeze

  def teardown
    @producer.close if @producer
  end

  def test_validate_options
    ex = assert_raises(GlassOctopus::OptionsInvalid) { GlassOctopus::PoseidonAdapter.new {} }
    assert_includes ex.errors, "Missing key: broker_list"
    assert_includes ex.errors, "Missing key: broker_list"
    assert_includes ex.errors, "Missing key: topic"
    assert_includes ex.errors, "Missing key: group"
  end

  def test_fetch_message_yield_messages
    integration_test!

    adapter = create_adapter
    send_message("key1", "value1")

    q = Queue.new
    Thread.new { q.pop; adapter.close }

    adapter.fetch_message do |message|
      assert_equal "value1", message.value
      assert_equal "key1", message.key
      assert_equal TEST_TOPIC, message.topic
      assert_equal 0, message.partition

      q << :done
    end
  end

  def send_message(key, value)
    @producer ||= Poseidon::Producer.new(
      [Docker.kafka_0_8_host], "poseidon_test_producer",
      partitioner: Proc.new { 0 } # send everything to 0 partition
    )
    @producer.send_messages([Poseidon::MessageToSend.new(TEST_TOPIC, value, key)])
  end

  def create_adapter
    GlassOctopus::PoseidonAdapter.new do |config|
      config.broker_list = [Docker.kafka_0_8_host]
      config.zookeeper_list = [Docker.zookeeper_host]
      config.topic = TEST_TOPIC
      config.group = TEST_GROUP
      config.logger = NullLogger.new
    end.connect
  end
end
