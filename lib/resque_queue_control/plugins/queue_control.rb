module Resque
  module Plugins
    module QueueControl
      include Resque::Helpers

      PAUSE_CHECK_INTERVAL = 10 # seconds to wait when queue is paused or busy
      LOCK_TIMEOUT = 60 * 60 * 24 * 5 # 5 days

      def lock_timeout
        Time.now.utc + LOCK_TIMEOUT + 1
      end

      # Overwrite this method to uniquely identify which mutex should be used
      # for a resque worker.
      def redis_key(*args)
        "lonely_job:#{@queue}"
      end

      def can_lock_queue?(*args)
        Resque.redis.setnx(redis_key(*args), lock_timeout)
      end

      def unlock_queue(*args)
        Resque.redis.del(redis_key(*args))
      end

      def reenqueue(*args)
        Resque.redis.lpush("queue:#{@queue}", Resque.encode(:class => self, :args => args))
      end

      def wait
        Kernel.sleep(@pause_check_interval || Resque::Plugins::QueueControl::PAUSE_CHECK_INTERVAL)
      end

      def before_perform_queue_control(*args)
        @queue = args.pop

        if ResqueQueueControlHelper.paused?(@queue)
          wait
          reenqueue(*args)
          raise Resque::Job::DontPerform.new "Queue #{@queue} is paused!"
        end

        unless can_lock_queue?(*args)
          wait
          reenqueue(*args)
          raise Resque::Job::DontPerform.new "Queue #{@queue} already has a job running!"
        end
      end

      def around_perform(*args)
        begin
          yield
        ensure
          unlock_queue(*args)
        end
      end

    end
  end
end
