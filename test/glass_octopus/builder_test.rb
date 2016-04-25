require "test_helper"
require "glass_octopus/builder"

class GlassOctopus::BuilderTest < Minitest::Test
  def test_use_appends_a_new_entry_and_makes_it_callable
    builder = GlassOctopus::Builder.new
    builder.use(->(ctx) { ctx[:called] = true })

    data = {}
    builder.call(data)

    assert data[:called], "middleware was not called"
  end

  def test_to_app_returns_a_callable_object
    builder = GlassOctopus::Builder.new
    assert_respond_to builder.to_app, :call
  end

  def test_run_sets_the_end_of_the_chain
    builder = GlassOctopus::Builder.new
    builder.use(lambda { |ctx| ctx[:order] << "middleware" })
    builder.run(lambda { |ctx| ctx[:order] << "app" })

    data = { order: [] }
    builder.call(data)

    assert_equal %w[middleware app], data[:order]
  end
end

class GlassOctopus::EntryTest < Minitest::Test
  def test_build_lamda_always_calls_next
    proc1 = Proc.new { |ctx| ctx[:proc1] = true}
    proc2 = Proc.new { |ctx| ctx[:proc2] = true }
    entry = GlassOctopus::Builder::Entry.new(proc1)

    mw = entry.build(proc2)

    data = {}
    mw.call(data)

    assert data[:proc1]
    assert data[:proc2]
  end

  def test_build_class
    mw_class = Class.new do
      attr_reader :next, :test_arg

      def initialize(next_mw, test_arg)
        @next = next_mw
        @test_arg = test_arg
      end

      def call(ctx)
      end
    end

    entry = GlassOctopus::Builder::Entry.new(mw_class, [:test])
    next_mw = ->(ctx) {}
    mw = entry.build(next_mw)

    assert_kind_of mw_class, mw
    assert_equal next_mw, mw.next
    assert_equal :test, mw.test_arg
  end
end
