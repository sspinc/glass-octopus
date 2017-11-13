# Glass Octopus

A Kafka consumer framework. Like Rack but for Kafka.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'glass-octopus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install glass-octopus

This gem requires Ruby 2.1 or higher.

## Getting started

Pick your adapter:

* For Kafka 0.8.x use poseidon and poseidon-cluster

        # in your Gemfile
        gem "glass-octopus"
        gem "poseidon", github: "bpot/poseidon"
        gem "poseidon_cluster", github: "bsm/poseidon_cluster"

* For Kafka 0.9+ use ruby-kafka

        # in your Gemfile
        gem "glass-octopus"
        gem "ruby-kafka"


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

For more examples look into the [examples](examples) directory.

For the API documentation please see the [documentation site][rubydoc]

## Development

Install docker and docker-compose to run Kafka and zookeeper for tests.

1. Set the `ADVERTISED_HOST` environment variable
2. Run `rake docker:up`
3. Now you can run the tests.

Run all tests including integration tests:

    $ rake test:all

Running tests without integration tests:

    $ rake # or rake test

When you are done run `rake docker:down` to clean up docker containers.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

[rubydoc]: http://www.rubydoc.info/github/sspinc/glass-octopus
