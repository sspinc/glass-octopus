require "minitest/autorun"
require "minitest/guard_minitest_plugin"

lib_path = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)


# HACK: minitest auto-discovers plugins and guard-minitest installs itself
# regardless whether we run it as part of guard or not. We monkey patch the
# guard-minitest plugin initialization to conditionally add the reporter.
module Minitest
  def self.plugin_guard_minitest_init(_options) # :nodoc:
    if ENV.keys.include?("GUARD_MINITEST")
      reporter << ::Guard::Minitest::Reporter.new
    end
  end
end
