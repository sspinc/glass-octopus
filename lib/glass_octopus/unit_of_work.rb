require "glass_octopus/context"

module GlassOctopus
  # Unit of work. Builds a context for a message and runs it through the
  # middleware stack. It catches and logs all application level exceptions.
  #
  # @api private
  class UnitOfWork
    attr_reader :message, :processor, :logger

    def initialize(message, processor, logger)
      @message   = message
      @processor = processor
      @logger    = logger
    end

    def perform
      processor.call(Context.new(message, logger))
    rescue => ex
      logger.logger.error("#{ex.class} - #{ex.message}:")
      logger.logger.error(ex.backtrace.join("\n")) if ex.backtrace
    end
  end
end
