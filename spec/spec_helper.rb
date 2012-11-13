require 'rubygems'
require 'bundler/setup'
require 'rspec'

require 'mock_redis'
require 'resque'
require 'resque_queue_control'

RSpec.configure do |config|
  config.before(:suite) do
    Resque.redis = MockRedis.new
  end

  config.before(:each) do
    Resque.redis.flushall
    Kernel.stub!(:sleep)
  end
end
