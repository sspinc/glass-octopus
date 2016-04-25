require "forwardable"

module GlassOctopus
  # Message context. Wraps a Kafka message and adds some convenience methods.
  #
  # @!attribute [r] application
  #   @return [Application] the application object.
  # @!attribute [rw] logger
  #   A logger object. Defaults to the application logger.
  # @!attribute [r] message
  #   @return [Message]
  class Context
    extend Forwardable
    attr_reader :message, :application
    attr_writer :logger

    # @!method [](key)
    #   Retrieves the +value+ object corresponding to the +key+ object.
    #   @param key key to retrieve
    # @!method []=(key, value)
    #   Associates +value+ with +key+.
    def_delegators :@data, :[], :[]=

    # @api private
    def initialize(message, app)
      @data        = {}
      @message     = message
      @application = app
    end

    def logger
      @logger || application.logger
    end
  end
end
