require 'spec_helper'

class PauseJob
  extend Resque::Plugins::QueueControl
  @queue = :test

  def self.perform(*args)
  end
end

describe Resque::Plugins::QueueControl do
  it "should be compliance with Resque::Plugin document" do
    expect { Resque::Plugin.lint(Resque::Plugins::QueueControl) }.to_not raise_error
  end

  it "should execute the job when queue is not paused" do
    Resque.enqueue(PauseJob)
    PauseJob.should_receive(:perform)

    Resque.reserve('test').perform
  end

  it "should not execute the job when queue is paused" do
    Resque.enqueue(PauseJob)
    Resque.size('test').should == 1

    job = Resque.reserve('test')
    ResqueQueueControlHelper.pause('test')
    job.perform

    Resque.size('test').should == 1
  end

  it "should not reserve the job when queue is paused" do
    ResqueQueueControlHelper.pause('test')
    Resque.enqueue(PauseJob)
    PauseJob.should_not_receive(:perform)

    Resque.reserve('test').should be_nil
  end

  it "should not change queued jobs when queue is paused" do
    Resque.enqueue(PauseJob, 1)
    Resque.enqueue(PauseJob, 2)
    Resque.enqueue(PauseJob, 3)
    jobs = Resque.redis.lrange('queue:test', 0, 2)

    job = Resque.reserve('test')
    ResqueQueueControlHelper.pause('test')
    job.perform

    remaining_jobs = Resque.redis.lrange('queue:test', 0, 2)
    jobs.should == remaining_jobs
  end

  it "should back to execute the job when queue is unpaused" do
    Resque.enqueue(PauseJob)

    job = Resque.reserve('test')
    ResqueQueueControlHelper.pause('test')
    job.perform
    Resque.size('test').should == 1

    ResqueQueueControlHelper.unpause('test')
    Resque.reserve('test').perform
    Resque.size('test').should == 0
  end

end
