require "test_helper"

require "logger"
require "stringio"
require "glass_octopus/middleware/common_logger"
require "glass_octopus/message"

class GlassOctopus::CommonLoggerTest < Minitest::Test
  def test_measure_runtime
    mw, io = setup_common_logger

    mw.call(Context.new(build_message))
    assert_match /runtime=.*ms/, io.string
  end

  def test_log_pre_and_post_message
    mw, io = setup_common_logger
    mw.call(Context.new(build_message))

    assert_equal 1, io.string.lines.size
    assert_match /Processed message/, io.string
  end

  def setup_common_logger
    io = StringIO.new
    logger = Logger.new(io)
    app = ->(ctx) {}
    mw = GlassOctopus::Middleware::CommonLogger.new(app, logger)

    return mw, io
  end

  def build_message
    GlassOctopus::Message.new("test", 0, 0, "key", "value")
  end

  Context = Struct.new(:message)
end
