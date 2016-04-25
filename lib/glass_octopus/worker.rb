require "glass_octopus/context"

module GlassOctopus
  # Unit of work. Builds a context for a message and runs it through the
  # middleware stack. It catches and logs all application level exceptions.
  #
  # @api private
  class Worker
    attr_reader :message, :processor, :app

    def initialize(message, processor, app)
      @message   = message
      @processor = processor
      @app       = app
    end

    def call
      processor.call(build_context)
    rescue => ex
      app.logger.error("#{ex.class} - #{ex.message}:")
      app.logger.error(ex.backtrace.join("\n")) if ex.backtrace
    end

    private

    def build_context
      Context.new(message, app)
    end
  end
end
