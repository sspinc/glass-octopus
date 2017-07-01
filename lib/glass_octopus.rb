require "glass_octopus/version"
require "glass_octopus/middleware"
require "glass_octopus/runner"
require "glass_octopus/application"
require "glass_octopus/builder"

module GlassOctopus
  # Run an application. The application can be anything that responds to
  # +#call+. It is invoked with with a context that has the message and other
  # goodies.
  #
  # @see Builder
  # @see Context
  #
  # @param app [#call] application to process messages
  # @yield [config] configure your application in this block, this is called
  #   before connecting to Kafka
  # @yieldparam config [Configuration] the configuration object
  # @raise [ArgumentError] when no block for configuration is passed
  def self.run(app, &block)
    raise ArgumentError, "A block must be given to set up the #{name}." unless block_given?
    go_app = Application.new(app, &block)
    Runner.run(go_app)
  end

  # Build a middleware stack.
  # Basically a shortcut to +Builder.new { }.to_app+
  #
  # @example
  #
  #   require "glass_octopus"
  #
  #   app = GlassOctopus.build do
  #     use GlassOctopus::Middleware::CommonLogger
  #
  #     run Proc.new { |context|
  #       puts "Hello, #{context.message.value}"
  #     }
  #   end
  #
  #   GlassOctopus.run(app) do |config|
  #     # set config here
  #   end
  #
  # @see Builder
  # @yield use the builder DSL to build your middleware stack
  # @return [#call] an application that can be fed into the {.run}
  def self.build(&block)
    Builder.new(&block).to_app
  end

  autoload :PoseidonAdapter, "glass_octopus/connection/poseidon_adapter.rb"
end
