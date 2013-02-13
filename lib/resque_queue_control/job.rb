module Resque
  class Job
    class <<self
      alias_method :origin_before_pause_reserve, :reserve

      def reserve(queue)
        return nil unless ResqueQueueControlHelper.can_reserve?(queue)
        origin_before_pause_reserve(queue)
      end

    end

    def args
      @payload['args'].push(@queue)
    end
  end
end
