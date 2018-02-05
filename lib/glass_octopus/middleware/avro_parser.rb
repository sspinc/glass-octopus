require 'avro_turf/messaging'
require "delegate"

module GlassOctopus
  module Middleware
    class AvroParser
      def initialize(app, schema_registry_url)
        @app = app
        @decoder = AvroTurf::Messaging.new(registry_url: schema_registry_url)
      end

      def call(ctx)
        message = @decoder.decode(ctx.message.value)
        ctx = ContextWithAvroParsedMessage.new(ctx, message)
        @app.call(ctx)
      end

      private

      class ContextWithAvroParsedMessage < SimpleDelegator
        attr_reader :params

        def initialize(wrapped_ctx, params)
          super(wrapped_ctx)
          @params = params
        end
      end
    end
  end
end
