require "glass_octopus/unit_of_work"

module GlassOctopus
  # @api private
  class Consumer
    attr_reader :connection, :processor, :app, :executor

    def initialize(connection, processor, app, executor)
      @connection = connection
      @processor  = processor
      @app        = app
      @executor   = executor
    end

    def run
      connection.fetch_message do |message|
        work = UnitOfWork.new(message, processor, logger)
        submit(work)
      end
    end

    def shutdown(timeout=10)
      connection.close
      executor.shutdown
      logger.info("Waiting for workers to terminate...")
      executor.wait_for_termination(timeout)
    end

    def submit(work)
      if executor.post(work) { |work| work.perform }
        logger.debug { "Accepted message: #{worker.message.to_h}" }
      else
        logger.warn { "Rejected message: #{worker.message.to_h}" }
      end
    rescue Concurrent::RejectedExecutionError => ex
      logger.warn { "Rejected message: #{worker.message.to_h}" }
    end

    def logger
      app.logger
    end
  end
end
