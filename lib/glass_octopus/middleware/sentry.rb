begin
  require "raven"
rescue LoadError
  raise "Can't find 'sentry-raven' gem. Please add it to your Gemfile or install it."
end

module GlassOctopus
  module Middleware
    class Sentry
      def initialize(app)
        @app = app
      end

      # Based on Raven::Rack integration
      def call(ctx)
        # clear context at the beginning of the processing to ensure a clean slate
        Raven::Context.clear!
        started_at = Time.now

        begin
          @app.call(ctx)
        rescue Raven::Error
          raise # Don't capture Raven errors
        rescue Exception => ex
          Raven.logger.debug("Collecting %p: %s" % [ ex.class, ex.message ])
          Raven.capture_exception(ex, :extra => { :message => ctx.message.to_h },
                                      :time_spent => Time.now - started_at)
          raise
        end
      end
    end
  end
end
