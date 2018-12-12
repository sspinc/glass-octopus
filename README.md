# Glass Octopus

A Kafka consumer framework. Like Rack but for Kafka.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'glass_octopus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install glass_octopus

This gem requires Ruby 2.1 or higher.

## Getting started

Pick your adapter:

* ruby-kafka

        # in your Gemfile
        gem "glass_octopus"
        gem "ruby-kafka"

Currently only `ruby-kafka` is supported.

```ruby
# in app.rb
require "bundler/setup"
require "glass_octopus"

app = GlassOctopus.build do
  use GlassOctopus::Middleware::CommonLogger

  run Proc.new { |ctx|
    puts "Got message: #{ctx.message.key} => #{ctx.message.value}"
  }
end

GlassOctopus.run(app) do |config|
  config.adapter :ruby_kafka do |kafka|
    kafka.broker_list = %[localhost:9092]
    kafka.topic       = "mytopic"
    kafka.group       = "mygroup"
    kafka.client      = { logger: config.logger }
  end
end
```

Run it with `bundle exec ruby app.rb`

### Handling Avro messages with Schema Registry

Glass Octopus can be used with Avro messages validated against a schema. For this, you need a running [Schema Registry](https://docs.confluent.io/current/schema-registry/docs/index.html) service.
You also need to have the `avro_turf` gem installed.

```
# in your Gemfile
gem "avro_turf"
```

Add the `AvroParser` middleware with the Schema Registry URL to your app.

```ruby
# in app.rb
app = GlassOctopus.build do
  use GlassOctopus::Middleware::AvroParser, "http://schema_registry_url:8081"
  ...
end
```

For more examples look into the [example](example) directory.

For the API documentation please see the [documentation site][rubydoc]

## Development

Install docker and docker-compose to run Kafka and Zookeeper for tests.

Start Kafka and Zookeeper

    $ docker-compose up

Run all tests including integration tests:

    $ rake test:all

Running tests without integration tests:

    $ rake # or rake test

When you are done run `docker-compose down` to clean up docker containers.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

[rubydoc]: http://www.rubydoc.info/github/sspinc/glass-octopus
