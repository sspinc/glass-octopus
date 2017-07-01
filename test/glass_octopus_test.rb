require "test_helper"
require "glass_octopus"

class GlassOctopusTest < Minitest::Test
  def test_run_raises_when_no_block_given
    app = Proc.new {}
    e = assert_raises(ArgumentError) do
      GlassOctopus.run(app)
    end

    assert_match /^A block must be given/, e.message
  end

  def test_running_with_runner
    app = Proc.new {}
    runner = Minitest::Mock.new

    runner.expect(:run, nil, [GlassOctopus::Application])
    GlassOctopus.run(app, runner: runner) {}

    assert runner.verify
  end

  class FakeRunner
    attr_reader :app
    def run(app)
      @app = app
    end
  end
end
