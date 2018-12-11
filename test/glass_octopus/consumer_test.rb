require "test_helper"
require "support/in_memory_connection"
require "concurrent"

require "glass_octopus/message"
require "glass_octopus/consumer"

class GlassOctopus::ConsumerTest < Minitest::Test

  def test_fetch_message_from_connection
    connection = Minitest::Mock.new
    consumer = new_consumer(connection)

    connection.expect(:fetch_message, nil)
    consumer.run

    assert connection.verify
  end

  def test_message_gets_processed
    connection = InMemoryConnection.new([GlassOctopus::Message.new])
    processor = Minitest::Mock.new
    consumer = new_consumer(connection, processor)

    processor.expect(:call, nil, [GlassOctopus::Context])
    consumer.run

    assert processor.verify
  end

  def test_shutdown_closes_the_connection
    connection = Minitest::Mock.new
    consumer = new_consumer(connection)

    connection.expect(:close, nil)
    consumer.shutdown

    assert connection.verify
  end

  def new_consumer(connection, processor=nil)
    processor ||= Proc.new {}
    logger = NullLogger.new
    executor = Concurrent::ImmediateExecutor.new

    GlassOctopus::Consumer.new(connection, processor, executor, logger)
  end
end
