require "glass_octopus/worker"

module GlassOctopus
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
        worker = Worker.new(message, processor, app)
        submit(worker)
      end
    end

    def shutdown(timeout=10)
      connection.close
      executor.shutdown
      app.logger.info("Waiting for workers to terminate...")
      executor.wait_for_termination(timeout)
    end

    private

    def submit(worker)
      if executor.post(worker) { |worker| worker.call }
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
