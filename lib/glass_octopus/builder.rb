require "glass_octopus/middleware/common_logger"

module GlassOctopus
  # GlassOctopus::Builder is a small DLS to build processing pipelines. It is
  # very similar to Rack::Builder.
  #
  # Middleware can be a class with a similar signature to Rack middleware. The
  # constructor needs to take an +app+ object which is basically the next
  # middleware in the stack and the instance of the class has to respond to
  # +#call(ctx)+.
  #
  # Lambdas/procs can also be used as middleware. In this case the middleware
  # does not have control over the execution of the next middleware: the next
  # one is *always* called.
  #
  # @example
  #   require "glass_octopus"
  #
  #   app = GlassOctopus::Builder.new do
  #     use GlassOctopus::Middleware::CommonLogger
  #     use GlassOctopus::Middleware::JsonParser
  #
  #     run Proc.new { |ctx|
  #       puts "Hello, #{ctx.params['name']}"
  #     }
  #   end.to_app
  #
  #   GlassOctopus.run(app) do |config|
  #     # set config here
  #   end
  #
  # @example Using lambdas
  #
  #   require "glass_octopus"
  #
  #   logger = Logger.new("log/example.log")
  #
  #   app = GlassOctopus::Builder.new do
  #     use lambda { |ctx| ctx.logger = logger }
  #
  #     run Proc.new { |ctx|
  #       ctx.logger.info "Hello, #{ctx.params['name']}"
  #     }
  #   end.to_app
  #
  #   GlassOctopus.run(app) do |config|
  #     # set config here
  #   end
  #
  class Builder
    def initialize(&block)
      @entries = []
      @app = ->(ctx) {}

      instance_eval(&block) if block_given?
    end

    # Append a middleware to the stack.
    #
    # @param klass [Class, #call] a middleware class or a callable object
    # @param args [Array] arguments to be passed to the klass constructor
    # @param block a block to be passed to klass constructor
    # @return [Builder] returns self so calls are chainable
    def use(klass, *args, &block)
      @entries << Entry.new(klass, args, block)
      self
    end

    # Sets the final step in the middleware pipeline, essentially the
    # application itself. Takes a parameter that responds to +#call(ctx)+.
    #
    # @param app [#call] the application to process messages
    # @return [Builder] returns self so calls are chainable
    def run(app)
      @app = app
      self
    end

    # Generate a new middleware stack from the registered entries.
    #
    # @return [#call] the entry point of the middleware stack which is callable
    #   and when called runs the whole stack.
    def to_app
      @entries.reverse_each.reduce(@app) do |app, current_entry|
        current_entry.build(app)
      end
    end

    # Generate the middleware stack and call it with the passed in context.
    #
    # @param context [Context] message context
    # @return [void]
    # @note This method instantiates a new middleware stack on every call.
    def call(context)
      to_app.call(context)
    end

    # Represents an entry in the middleware stack.
    # @api private
    Entry = Struct.new(:klass, :args, :block) do
      def build(next_middleware)
        if klass.is_a?(Class)
          klass.new(next_middleware, *args, &block)
        elsif klass.respond_to?(:call)
          lambda do |context|
            klass.call(context)
            next_middleware.call(context)
          end
        else
          raise ArgumentError, "Invalid middleware, it must respond to `call`: #{klass.inspect}"
        end
      end
    end
  end
end
