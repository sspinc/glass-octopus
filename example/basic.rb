require "bundler/setup"
require "glass_octopus"

app = GlassOctopus::Builder.new do
  use GlassOctopus::Middleware::CommonLogger

  run Proc.new { |ctx|
    puts "Got message: #{ctx.message.key} => #{ctx.message.value}"
  }
end.to_app

GlassOctopus::Application.run(app) do |config|
  config.consumer.broker_list = %w[localhost:9092]
  config.consumer.zookeeper_list = %w[localhost:2181]
  config.consumer.topic = "mytopic"
  config.consumer.group = "mygroup"
end

