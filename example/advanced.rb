require "bundler/setup"
require "glass_octopus"

app = GlassOctopus::Builder.new do
  use GlassOctopus::Middleware::CommonLogger

  run Proc.new { |ctx|
    puts "Got message: #{ctx.message.key} => #{ctx.message.value}"
  }
end.to_app

GlassOctopus.run(app) do |config|
  config.consumer.broker_list = %w[localhost:9092]
  config.consumer.zookeeper_list = %w[localhost:2181]
  config.consumer.topic = "mytopic"
  config.consumer.group = "mygroup"

  config.logger = config.consumer.logger = Logger.new("glass_octopus.log")

  config.executor = Concurrent::ThreadPoolExecutor.new(
    max_threads: 25,
    min_threads: 7
  )

  config.shutdown_timeout = 30
end

