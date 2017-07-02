require "bundler/setup"
require "glass_octopus"

app = GlassOctopus.build do
  use GlassOctopus::Middleware::CommonLogger

  run Proc.new { |ctx|
    puts "Got message: #{ctx.message.key} => #{ctx.message.value}"
  }
end

def array_from_env(key, default:)
  return default unless ENV.key?(key)
  ENV.fetch(key).split(",").map(&:strip)
end

GlassOctopus.run(app) do |config|
  config.adapter :poseidon do |kafka_config|
    kafka_config.broker_list    = array_from_env("KAFKA_BROKER_LIST", default: %w[localhost:9092])
    kafka_config.zookeeper_list = array_from_env("ZOOKEEPER_LIST", default: %w[localhost:2181])
    kafka_config.topic          = ENV.fetch("KAFKA_TOPIC", "mytopic")
    kafka_config.group          = ENV.fetch("KAFKA_GROUP", "mygroup")
  end
end
