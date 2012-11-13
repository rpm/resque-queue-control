module Resque
  module Plugins
    module PauseQueue
      include Resque::Helpers
      PAUSE_CHECK_INTERVAL = 10 #seconds to wait when queue is paused

      def before_perform_pause(*args)
        if ResqueQueueControlHelper.paused?(@queue)
          Kernel.sleep(@pause_check_interval || Resque::Plugins::PauseQueue::PAUSE_CHECK_INTERVAL)
          ResqueQueueControlHelper.check_paused(:queue => @queue, :class => self, :args => args)
        end
      end
    end
  end
end
