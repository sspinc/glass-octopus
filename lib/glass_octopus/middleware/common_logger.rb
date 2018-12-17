require "benchmark"

module GlassOctopus
  module Middleware
    class CommonLogger
      FORMAT = "Processed message. topic=%s, partition=%d, key=%s, runtime=%fms".freeze

      def initialize(app, logger=nil, log_level=:info)
        @app = app
        @logger = logger
        @log_level = log_level
      end

      def call(ctx)
        log(ctx) { @app.call(ctx) }
      end

      private

      def log(ctx)
        logger = @logger || ctx.logger

        runtime = Benchmark.realtime { yield }
        runtime *= 1000 # Convert to milliseconds

        logger.send(@log_level) { format_message(ctx, runtime) }
      end

      def format_message(ctx, runtime)
        format(FORMAT,
          ctx.message.topic, ctx.message.partition, ctx.message.key, runtime)
      end
    end
  end
end
