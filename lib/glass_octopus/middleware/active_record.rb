begin
  require "active_record"
rescue LoadError
  raise "Can't find 'activerecord' gem. Please add it to your Gemfile or install it."
end

module GlassOctopus
  module Middleware
    class ActiveRecord
      def initialize(app)
        @app = app
      end

      def call(ctx)
        @app.call(ctx)
      ensure
        ::ActiveRecord::Base.clear_active_connections!
      end
    end
  end
end
