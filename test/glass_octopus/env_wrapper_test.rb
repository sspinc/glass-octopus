require "test_helper"
require "glass_octopus/env"

class GlassOctopus::EnvWrapperTest < Minitest::Test
  def setup
    @env = GlassOctopus::EnvWrapper.new({})
  end

  def test_integer_returns_Integer_type
    @env["INT"] = "123"

    assert_kind_of Integer, @env.integer("INT")
    assert_equal 123, @env.integer("INT")
  end

  def test_integer_parsing_fails_loudly
    @env["INT"] = "not an integer"
    assert_raises(ArgumentError) { @env.integer("INT") }
  end

  def test_integer_fails_loudly_when_key_not_present
    assert_raises(TypeError) { @env.integer("INT") }
  end

  def test_integer_default
    assert_equal 12, @env.integer("INT", default: 12)
  end

  def test_boolean
    {
      "1"         => true,
      "on"        => true,
      "y"         => true,
      "yes"       => true,
      "t"         => true,
      "true"      => true,
      "no"        => false,
      "something" => false,
      "false"     => false,
      "0"         => false,
    }.each do |value, expected|
      @env["BOOL"] = value
      assert_equal expected, @env.boolean("BOOL")
    end
  end

  def test_boolean_default
    assert_equal nil, @env.boolean("BOOL")
    assert_equal true, @env.boolean("BOOL", default: true)
  end

  def test_array_default
    assert_equal [], @env.array("ARY")
    assert_equal %w[test], @env.array("ARY", default: %w[test])
  end

  def test_array_splits_on_delimiter
    @env["ARY"] = "localhost:9092,localhost:9093"
    assert_equal %w[localhost:9092 localhost:9093], @env.array("ARY")

    @env["ARY"] = "pipe|delimiter"
    assert_equal %w[pipe delimiter], @env.array("ARY", delim: "|")
  end
end
