require "delegate"
require "concurrent"

module GlassOctopus
  # BoundedExecutor wraps an existing executor implementation and provides
  # throttling for job submission. It delegates every method to the wrapped
  # executor.
  #
  # Implementation is based on the Java Concurrency In Practice book. See:
  # http://jcip.net/listings/BoundedExecutor.java
  #
  # @example
  #   pool = BoundedExecutor.new(Concurrent::FixedThreadPool.new(2), 2)
  #
  #   pool.post { puts "something time consuming" }
  #   pool.post { puts "something time consuming" }
  #
  #   # This will block until the other submitted jobs are done.
  #   pool.post { puts "something time consuming" }
  #
  class BoundedExecutor < SimpleDelegator
    # @param executor the executor implementation to wrap
    # @param limit [Integer] maximum number of jobs that can be submitted
    def initialize(executor, limit:)
      super(executor)
      @semaphore = Concurrent::Semaphore.new(limit)
    end

    # Submit a task to the executor for asynchronous processing. If the
    # submission limit is reached {#post} will block until there is a free
    # worker to accept the new task.
    #
    # @param args [Array] arguments to pass to the task
    # @return [Boolean] +true+ if the task was accepted, false otherwise
    def post(*args, &block)
      return false unless running?

      @semaphore.acquire
      begin
        __getobj__.post(args, block) do |args, block|
          begin
            block.call(*args)
          ensure
            @semaphore.release
          end
        end
      rescue Concurrent::RejectedExecutionError
        @semaphore.release
        raise
      end
    end
  end
end
