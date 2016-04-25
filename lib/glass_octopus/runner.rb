require "singleton"

module GlassOctopus
  # A very simple runner that takes an app and handles graceful shutdown for
  # SIGINT and SIGTERM.
  #
  # The {#run} method alters the processes state globally and irreversibly by
  # registering signal handlers. The Runner class is a singleton and can only be
  # started once.
  #
  # Runner runs the application in the main thread. When a signal hits the
  # process the control is transferred to the signal handler which will raise an
  # Interrupt exception which kicks off the graceful shutdown. During shutdown
  # no more messages are read because everything happens in the main thread.
  #
  # Runner does not provide any meaningful error handling. Errors are logged and
  # then the process exits with status code 1.
  #
  # @api private
  class Runner
    include Singleton

    # Shortcut to {#run}.
    # @return [void]
    def self.run(app)
      instance.run(app)
    end

    # Starts the application and blocks until the process gets a SIGTERM or
    # SIGINT signal.
    #
    # @param app the application to run
    # @return [void]
    def run(app)
      return if running?
      running!

      # To support JRuby Ctrl+C as MRI does.
      # See: https://github.com/jruby/jruby/issues/1639
      trap(:INT)  { Thread.main.raise Interrupt }
      trap(:TERM) { Thread.main.raise Interrupt }

      app.run
    rescue Interrupt
      app.logger.info("Shutting down...")
      app.shutdown
      app.logger.info("Bye.")
    rescue => ex
      app.logger.fatal("#{ex.class} - #{ex.message}:")
      app.logger.fatal(ex.backtrace.join("\n")) if ex.backtrace
      exit(1)
    end

    # Determines whether the application is running or not.
    # @return [Boolean]
    def running?
      @running
    end

    private

    attr_reader :logger

    def running!
      @running = true
    end
  end
end
