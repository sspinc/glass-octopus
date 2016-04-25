begin
  require "mongoid"
rescue LoadError
  raise "Can't find 'mongoid' gem. Please add it to your Gemfile or install it."
end

module GlassOctopus
  module Middleware
    class Mongoid
      def initialize(app)
        @app = app
      end

      def call(ctx)
        Mongoid.unit_of_work { @app.call(ctx) }
      end
    end
  end
end
