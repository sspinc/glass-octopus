require "test_helper"
require "ostruct"
require "glass_octopus/message"
require "glass_octopus/middleware/json_parser"

class GlassOctopus::JsonParserTest < Minitest::Test
  def test_extend_context_with_params
    instance = setup_middleware

    ctx = instance.call(build_context)

    assert_respond_to ctx, :params
  end

  def test_json_parsed_into_a_hash
    instance = setup_middleware
    json = %({"key": "value"})

    ctx = instance.call(build_context(json))

    assert_equal({ "key" => "value" }, ctx.params)
  end

  def test_json_parsed_into_given_class
    params_class = Struct.new(:name, :age) do
      def initialize(hash)
        hash.each { |k,v| public_send("#{k}=", v) }
      end
    end
    instance = setup_middleware(class: params_class)
    json = %({"name": "John Doe", "age": 32})

    ctx = instance.call(build_context(json))
    assert_kind_of params_class, ctx.params
    assert_equal "John Doe", ctx.params.name
  end

  def setup_middleware(options={})
    next_middleware = ->(ctx) { ctx }
    GlassOctopus::Middleware::JsonParser.new(next_middleware, options)

  end

  def build_context(json="{}")
    message = GlassOctopus::Message.new("topic", 0, 0, "key", json)
    OpenStruct.new(message: message)
  end
end
