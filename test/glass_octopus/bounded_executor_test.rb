require "test_helper"
require "glass_octopus/bounded_executor"

class GlassOctopus::BoundedExecutorTest < Minitest::Test
  def test_post_returns_false_after_shutdown
    executor = Concurrent::ImmediateExecutor.new
    pool = GlassOctopus::BoundedExecutor.new(executor, limit: 1)
    pool.shutdown

    assert_equal false, pool.post {}
  end

  def test_post_returns_true_for_successful_submission
    executor = Concurrent::ImmediateExecutor.new
    pool = GlassOctopus::BoundedExecutor.new(executor, limit: 1)

    assert_equal true, pool.post {}
  end
end
