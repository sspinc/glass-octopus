require "forwardable"

module GlassOctopus
  # Message context. Wraps a Kafka message and adds some convenience methods.
  #
  # @!attribute [rw] logger
  #   A logger object. Defaults to the application logger.
  # @!attribute [r] message
  #   A message read from Kafka.
  #   @return [Message]
  class Context
    extend Forwardable
    attr_reader :message
    attr_accessor :logger

    # @!method [](key)
    #   Retrieves the +value+ object corresponding to the +key+ object.
    #   @param key key to retrieve
    # @!method []=(key, value)
    #   Associates +value+ with +key+.
    def_delegators :@data, :[], :[]=

    # @api private
    def initialize(message, logger)
      @data    = {}
      @message = message
      @logger  = logger
    end
  end
end
