require "glass_octopus/version"
require "glass_octopus/middleware"
require "glass_octopus/runner"
require "glass_octopus/application"

module GlassOctopus
  autoload :Builder, "glass_octopus/builder"

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
end
