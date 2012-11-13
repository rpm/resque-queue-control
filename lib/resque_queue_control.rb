require 'resque_queue_control/plugins/jobs_per_queue'
require 'resque_queue_control/plugins/pause_queue'
require 'resque_queue_control/resque_queue_control_helper'
require 'resque_queue_control/job'

module Resque
  module Plugins
    module QueueControl
      include JobsPerQueue

    end
  end
end
