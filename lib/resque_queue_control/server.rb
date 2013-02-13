require 'resque'
require 'resque/server'
require File.expand_path(File.join('../','resque_queue_control'), File.dirname(__FILE__))

# Extends Resque Web Based UI.
# Structure has been borrowed from ResqueScheduler.
module ResqueQueueControl
  module Server
    include Resque::Helpers

    def self.erb_path(filename)
      File.join(File.dirname(__FILE__), 'server', 'views', filename)
    end

    def self.public_path(filename)
      File.join(File.dirname(__FILE__), 'server', 'public', filename)
    end

    def self.included(base)

      base.class_eval do

        helpers do
          def paused?(queue)
            ResqueQueueControlHelper.paused?(queue)
          end
          def super_paused?(queue)
            ResqueQueueControlHelper.super_paused?(queue)
          end
        end

        mime_type :json, 'application/json'

        get '/pause' do
          erb File.read(ResqueQueueControl::Server.erb_path('pause.erb'))
        end

        post '/pause' do
          action = params['action']

          unless params['queue_name'].empty?
            case action.to_s.downcase
              when 'pause'
                ResqueQueueControlHelper.pause(params['queue_name'])
              when 'unpause'
                ResqueQueueControlHelper.unpause(params['queue_name'])
              when 'super_pause'
                ResqueQueueControlHelper.super_pause(params['queue_name'])
              when 'super_unpause'
                ResqueQueueControlHelper.super_unpause(params['queue_name'])
            end
          end
          content_type :json
          encode(:queue_name => params['queue_name'], :action => action)
        end

        get /pause\/public\/([a-z]+\.[a-z]+)/ do
          send_file ResqueQueueControl::Server.public_path(params[:captures].first)
        end
      end
    end

    Resque::Server.tabs << 'Pause'
  end
end

Resque.extend ResqueQueueControl
Resque::Server.class_eval do
  include ResqueQueueControl::Server
end
