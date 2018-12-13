require "glass_octopus/context"

module GlassOctopus
  # @api private
  class Consumer
    attr_reader :connection, :processor, :logger, :thread

    def initialize(connection, processor,  logger)
      @connection = connection
      @processor  = processor
      @logger     = logger
    end

    def start
      @thread = Thread.new { run }
      nil
    end

    def healthy?
      thread.nil? ? true : thread.alive?
    end

    def run
      connection.fetch_message do |message|
        process_message(message)
      end
    end

    def shutdown
      connection.close
    end

    # Unit of work. Builds a context for a message and runs it through the
    # middleware stack. It catches and logs all application level exceptions.
    def process_message(message)
      processor.call(Context.new(message, logger))
    rescue => ex
      logger.error("#{ex.class} - #{ex.message}:")
      logger.error(ex.backtrace.join("\n")) if ex.backtrace
    end
  end
end
