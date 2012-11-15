require 'spec_helper'

class QueueControlJob
  extend Resque::Plugins::QueueControl

  def self.perform(*args); end
end

class QueueControlWithCustomRedisKey
  extend Resque::Plugins::QueueControl

  def redis_key(account_id, *args)
    "lonely_job:#{@queue}:#{account_id}"
  end

  def self.perform(account_id, *args); end
end

describe Resque::Plugins::QueueControl do
  context "pausing jobs" do
    
    it "should be compliance with Resque::Plugin document" do
      expect { Resque::Plugin.lint(Resque::Plugins::QueueControl) }.to_not raise_error
    end
    
    it "should execute the job when queue is not paused" do
      Resque.enqueue_to(:test, QueueControlJob)
      QueueControlJob.should_receive(:perform)
    
      Resque.reserve('test').perform
    end
    
    it "should not execute the job when queue is paused" do
      Resque.enqueue_to(:test, QueueControlJob)
      Resque.size('test').should == 1
    
      job = Resque.reserve('test')
      ResqueQueueControlHelper.pause('test')
      job.perform
    
      Resque.size('test').should == 1
    end
    
    it "should not reserve the job when queue is paused" do
      ResqueQueueControlHelper.pause('test')
      Resque.enqueue_to(:test, QueueControlJob)
      QueueControlJob.should_not_receive(:perform)
    
      Resque.reserve('test').should be_nil
    end
    
    it "should not change queued jobs when queue is paused" do
      Resque.enqueue_to(:test, QueueControlJob, 1)
      Resque.enqueue_to(:test, QueueControlJob, 2)
      Resque.enqueue_to(:test, QueueControlJob, 3)
      jobs = Resque.redis.lrange('queue:test', 0, 2)
    
      job = Resque.reserve('test')
      ResqueQueueControlHelper.pause('test')
      job.perform
    
      remaining_jobs = Resque.redis.lrange('queue:test', 0, 2)
      jobs.should == remaining_jobs
    end
    
    it "should back to execute the job when queue is unpaused" do
      Resque.enqueue(QueueControlJob)
    
      job = Resque.reserve('test')
      ResqueQueueControlHelper.pause('test')
      job.perform
      Resque.size('test').should == 1
    
      ResqueQueueControlHelper.unpause('test')
      Resque.reserve('test').perform
      Resque.size('test').should == 0
    end
  end

  context "locking queues" do
    describe ".can_lock_queue?" do
      it 'can lock a queue' do
        QueueControlJob.can_lock_queue?(:test).should be_true
      end

      it 'cannot lock an already locked queue' do
        QueueControlJob.can_lock_queue?(:test).should be_true
        QueueControlJob.can_lock_queue?(:test).should be_false
      end
    end

    describe "using the default redis key" do
      it 'should lock and unlock the queue' do
        job = Resque::Job.new(:test, { 'class' => 'QueueControlJob', 'args' => %w[account_one job_one] })

        # job is the first QueueControlJob to run so it can lock the queue and perform
        QueueControlJob.should_receive(:can_lock_queue?).and_return(true)

        # but it should also clean up after itself
        QueueControlJob.should_receive(:unlock_queue)

        job.perform
      end

      it 'should clean up lock even with catastrophic job failure' do
        job = Resque::Job.new(:test, { 'class' => 'QueueControlJob', 'args' => %w[account_one job_one] })

        # job is the first QueueControlJob to run so it can lock the queue and perform
        QueueControlJob.should_receive(:can_lock_queue?).and_return(true)

        # but we have a catastrophic job failure
        QueueControlJob.should_receive(:perform).and_raise(Exception)

        # and still it should clean up after itself
        QueueControlJob.should_receive(:unlock_queue)

        # unfortunately, the job will be lost but resque doesn't guarantee jobs
        # aren't lost
        -> { job.perform }.should raise_error(Exception)
      end

      it 'should place self at the head of the queue if unable to acquire the lock' do
        job1_payload = %w[account_one job_one]
        job2_payload = %w[account_one job_two]
        Resque::Job.create(:test, 'QueueControlJob', job1_payload)
        Resque::Job.create(:test, 'QueueControlJob', job2_payload)

        QueueControlJob.should_receive(:can_lock_queue?).and_return(false)

        # perform returns false when DontPerform exception is raised in
        # before_perform callback
        job1 = Resque.reserve(:test)
        job1.perform.should be_false

        first_queue_element = Resque.reserve(:test)
        first_queue_element.payload["args"].should == [job1_payload]
      end

      it "should not take a job off the queue if the queue is locked" do
        job1_payload = %w[account_one job_one]
        job2_payload = %w[account_one job_two]
        Resque::Job.create(:test, 'QueueControlJob', job1_payload)
        Resque::Job.create(:test, 'QueueControlJob', job2_payload)

        QueueControlJob.should_receive(:unlock_queue).and_return(false)

        job1 = Resque.reserve(:test)
        job1.perform

        job2 = Resque.reserve(:test)
        job2.should be_nil
      end
    end

    describe "with a custom redis_key" do
      it 'should lock and unlock the queue' do
        job = Resque::Job.new(:test, { 'class' => 'QueueControlWithCustomRedisKey', 'args' => %w[account_one job_one] })

        # job is the first QueueControlWithCustomRedisKey to run so it can lock the queue and perform
        QueueControlWithCustomRedisKey.should_receive(:can_lock_queue?).and_return(true)

        # but it should also clean up after itself
        QueueControlWithCustomRedisKey.should_receive(:unlock_queue)

        job.perform
      end

      it 'should clean up lock even with catastrophic job failure' do
        job = Resque::Job.new(:test, { 'class' => 'QueueControlWithCustomRedisKey', 'args' => %w[account_one job_one] })

        # job is the first QueueControlWithCustomRedisKey to run so it can lock the queue and perform
        QueueControlWithCustomRedisKey.should_receive(:can_lock_queue?).and_return(true)

        # but we have a catastrophic job failure
        QueueControlWithCustomRedisKey.should_receive(:perform).and_raise(Exception)

        # and still it should clean up after itself
        QueueControlWithCustomRedisKey.should_receive(:unlock_queue)

        # unfortunately, the job will be lost but resque doesn't guarantee jobs
        # aren't lost
        -> { job.perform }.should raise_error(Exception)
      end

      it 'should place self at the head of the queue if unable to acquire the lock' do
        job1_payload = %w[account_one job_one]
        job2_payload = %w[account_one job_two]
        Resque::Job.create(:test, 'QueueControlWithCustomRedisKey', job1_payload)
        Resque::Job.create(:test, 'QueueControlWithCustomRedisKey', job2_payload)

        QueueControlWithCustomRedisKey.should_receive(:can_lock_queue?).and_return(false)

        # perform returns false when DontPerform exception is raised in
        # before_perform callback
        job1 = Resque.reserve(:test)
        job1.perform.should be_false

        first_queue_element = Resque.reserve(:test)
        first_queue_element.payload["args"].should == [job1_payload]
      end
    end
  end
end