require "test_helper"
require "support/in_memory_connection"

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

  def test_exceptions_are_caught_and_logged
    processor = ->(ctx) { raise StandardError, "test error" }
    io = StringIO.new
    logger = Logger.new(io)
    connection = InMemoryConnection.new([GlassOctopus::Message.new])
    consumer = new_consumer(connection, processor, logger)

    consumer.run

    assert_match /StandardError - test error/, io.string
  end

  def new_consumer(connection, processor=nil, logger=nil)
    processor ||= Proc.new {}
    logger ||= NullLogger.new

    GlassOctopus::Consumer.new(connection, processor, logger)
  end
end
