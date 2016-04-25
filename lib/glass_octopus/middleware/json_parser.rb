require "json"
require "delegate"

module GlassOctopus
  module Middleware
    class JsonParser
      def initialize(app, options={})
        @app = app
        @klass = options.delete(:class)
        @encoding = options.delete(:encoding)
        @options = options
      end

      def call(ctx)
        message = parse(ensure_encoding(ctx.message.value))
        ctx = ContextWithJsonParsedMessage.new(ctx, message)
        @app.call(ctx)
      end

      private

      def parse(str)
        hash = JSON.parse(str, { :create_additions => false }.merge(@options))
        @klass ? @klass.new(hash) : hash
      end

      def ensure_encoding(value)
        return value unless @encoding
        value.encode(@encoding, invalid: :replace, undef: :replace, replace: '')
      end

      class ContextWithJsonParsedMessage < SimpleDelegator
        attr_reader :params

        def initialize(wrapped_ctx, params)
          super(wrapped_ctx)
          @params = params
        end
      end
    end
  end
end
