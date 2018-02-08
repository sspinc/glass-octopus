require "minitest/autorun"
require "minitest/color"
require "minitest/guard_minitest_plugin"
require "support/docker"
require "sinatra"
require "webmock/minitest"

lib_path = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

class Minitest::Test
  def integration_test!
    skip unless ENV.key?("TEST_KAFKA_INTEGRATION")
  end
end
