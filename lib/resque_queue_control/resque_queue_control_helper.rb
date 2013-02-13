module ResqueQueueControlHelper
  class << self
    def paused?(queue)
      !Resque.redis.get("pause:queue:#{queue}").nil?
    end

    def pause(queue)
      Resque.redis.set "pause:queue:#{queue}", true
    end

    def unpause(queue)
      Resque.redis.del "pause:queue:#{queue}"
    end

    def super_paused?(queue)
      !Resque.redis.get("super_pause:queue:#{queue}").nil?
    end

    def super_pause(queue)
      Resque.redis.set "super_pause:queue:#{queue}", true
    end

    def super_unpause(queue)
      Resque.redis.del "super_pause:queue:#{queue}"
    end

    def locked?(queue)
      Resque.redis.exists "lonely_job:#{queue}"
    end

    def unlock(queue)
      Resque.redis.del "lonely_job:#{queue}"
    end

    def can_reserve?(queue)
      return false if paused?(queue)
      return false if super_paused?(queue)
      return false if locked?(queue)
      true
    end
  end
end
