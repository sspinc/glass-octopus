require "stringio"
require "logger"
require "test_helper"
require "glass_octopus/unit_of_work"

class GlassOctopus::UnitOfWorkTest < Minitest::Test
  def test_processor_called_with_context
    processor = Minitest::Mock.new
    message = Object.new
    app = Object.new

    processor.expect(:call, nil, [GlassOctopus::Context])
    GlassOctopus::UnitOfWork.new(message, processor, app).perform

    assert processor.verify
  end

  def test_exceptions_are_caught_and_logged
    processor = ->(ctx) { raise StandardError, "an error..." }
    app, io = new_app
    message = Object.new
    worker = GlassOctopus::UnitOfWork.new(message, processor, app)

    worker.perform
    assert_match /StandardError - an error.../, io.string
  end

  def new_app
    log_io = StringIO.new
    return App.new(Logger.new(log_io)), log_io
  end

  App = Struct.new(:logger)
end
