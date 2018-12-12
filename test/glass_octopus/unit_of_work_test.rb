require "stringio"
require "logger"
require "test_helper"
require "glass_octopus/unit_of_work"

class GlassOctopus::UnitOfWorkTest < Minitest::Test
  def test_processor_called_with_context
    processor = Minitest::Mock.new
    message = GlassOctopus::Message.new
    logger = NullLogger.new

    processor.expect(:call, nil, [GlassOctopus::Context])
    GlassOctopus::UnitOfWork.new(message, processor, logger).perform

    assert processor.verify
  end

  def test_exceptions_are_caught_and_logged
    processor = ->(ctx) { raise StandardError, "an error..." }
    io = StringIO.new
    logger = Logger.new(io)
    message = GlassOctopus::Message.new
    work = GlassOctopus::UnitOfWork.new(message, processor, logger)

    work.perform
    assert_match /StandardError - an error.../, io.string
  end
end
