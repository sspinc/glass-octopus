begin
  require 'new_relic/agent'
rescue LoadError
  raise "Can't find 'newrelic_rpm' gem. Please add it to your Gemfile or install it."
end

module GlassOctopus
  module Middleware
    class NewRelic
      include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

      DEFAULT_OPTIONS = {
        :name => "call",
        :category => "OtherTransaction/GlassOctopus",
      }.freeze

      def initialize(app, klass, options={})
        @app = app
        @options = DEFAULT_OPTIONS.merge(class_name: klass.name).merge(options)
      end

      def call(ctx)
        options = @options.merge(params: {
          topic: ctx.message.topic,
          partition: ctx.message.partition,
          offset: ctx.message.offset,
        })
        perform_action_with_newrelic_trace(options) do
          @app.call(ctx)
        end
      rescue Exception => ex
        ::NewRelic::Agent.notice_error(ex, :custom_params => { :message => ctx.message.to_h })
        raise
      end
    end
  end
end
