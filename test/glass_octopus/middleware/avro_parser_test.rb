require 'avro_turf/test/fake_confluent_schema_registry_server'
require 'webmock/minitest'

require "test_helper"
require "ostruct"
require "glass_octopus/message"
require "glass_octopus/middleware/avro_parser"


class GlassOctopus::AvroParserTest < Minitest::Test
  def setup
    @logger = NullLogger.new
    @registry_url = "http://registry.example.com"
    stub_request(:any, /^#{@registry_url}/).to_rack(FakeConfluentSchemaRegistryServer)
    FakeConfluentSchemaRegistryServer.clear
    @avro = AvroTurf::Messaging.new(
      registry_url: @registry_url,
      schemas_path: 'test/fixtures/schemas',
      logger: @logger)
  end

  def test_avro_parsed_into_a_hash
    instance = setup_middleware

    hash = {"full_name" => "Wonder Woman"}
    data = @avro.encode(hash, schema_name: 'person')
    ctx = instance.call(build_context(data))

    assert_equal(hash, ctx.params)
  end

  def setup_middleware()
    next_middleware = ->(ctx) { ctx }
    GlassOctopus::Middleware::AvroParser.new(next_middleware, @registry_url, logger: @logger)
  end

  def build_context(data)
    message = GlassOctopus::Message.new("topic", 0, 0, "key", data)
    OpenStruct.new(message: message)
  end

end

