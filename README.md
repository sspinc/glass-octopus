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

Currently only `ruby-kafka` is supported out of the box. If you need to use another adapter you can pass a class to `config.adapter`. See documentation for `GlassOctopus::Configuration#adapter`.

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
    kafka.group_id    = "mygroup"
    kafka.client_id   = "myapp"
  end
end
```

Run it with `bundle exec ruby app.rb`

For more examples look into the [example](example) directory.

For the API documentation please see the [documentation site][rubydoc]

### Handling Avro messages with Schema Registry

Glass Octopus can be used with Avro messages validated against a schema. For this, you need a running [Schema Registry](https://docs.confluent.io/current/schema-registry/docs/index.html) service.
You also need to have the `avro_turf` gem installed.

```ruby
# in your Gemfile
gem "avro_turf"
```

Add the `AvroParser` middleware with the Schema Registry URL to your app.

```ruby
# in app.rb
app = GlassOctopus.build do
  use GlassOctopus::Middleware::AvroParser, "http://schema_registry_url:8081"
  # ...
end
```

### Supported middleware

* ActiveRecord

    Return any active connection to the pool after the message has been processed.

    ```ruby
    app = GlassOctopus.build do
      use GlassOctopus::Middleware::ActiveRecord
      # ...
    end
    ```

* New Relic

    Record message processing as background transactions. Also captures uncaught exceptions.

    ```ruby
    app = GlassOctopus.build do
      use GlassOctopus::Middleware::NewRelic, MyConsumer
      # ...
    end
    ```

* Sentry

    Report uncaught exceptions to Sentry.

    ```ruby
    app = GlassOctopus.build do
      use GlassOctopus::Middleware::Sentry
      # ...
    end
    ```

* Common logger

    Log processed messages and runtime of the processing.

    ```ruby
    app = GlassOctopus.build do
      use GlassOctopus::Middleware::CommonLogger
      # ...
    end
    ```

* Parse messages as JSON

    Parse message value as JSON. The resulting hash is placed in `context.params`.

    ```ruby
    app = GlassOctopus.build do
      use GlassOctopus::Middleware::JsonParser
      # ...
      run MyConsumer
    end

    class MyConsumer
      def call(ctx)
        puts ctx.params # message value parsed as JSON
        puts ctx.message # Raw unaltered message
      end
    end
    ```

    Optionally you can specify a class to be instantiated with the message hash.

    ```ruby
    app = GlassOctopus.build do
      use GlassOctopus::Middleware::JsonParser, class: MyMessage
      run MyConsumer
    end

    class MyMessage
      def initialize(attributes)
        attributes.each { |k,v| public_send("#{k}=", v) }
      end
    end
    ```

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
