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
  end
end
