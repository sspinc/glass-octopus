require "test_helper"

require "glass_octopus/configuration"

class GlassOctopus::ConfigurationTest < Minitest::Test
  def test_build_adapter_for_class
    config = GlassOctopus::Configuration.new

    adapter = config.build_adapter(TestAdapter)

    refute_nil adapter
    assert_instance_of TestAdapter, adapter
  end

  def test_build_adapter_ruby_kafka
    config = GlassOctopus::Configuration.new

    adapter = config.build_adapter(:ruby_kafka) do |c|
      c.broker_list = %w[localhost:9092]
      c.group_id = "test"
      c.topic = "test-topic"
    end

    assert_instance_of GlassOctopus::RubyKafkaAdapter, adapter
  end

  def test_build_adapter_passes_on_block
    config = GlassOctopus::Configuration.new

    adapter = config.build_adapter(TestAdapter) do |arg|
      assert_equal 42, arg
    end

    refute_nil adapter
  end

  class TestAdapter
    def initialize
      yield 42 if block_given?
    end
  end
end
