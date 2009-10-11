require 'spidr/agent'

require 'spec_helper'
require 'helpers/course'

describe Agent do
  include Helpers::Course

  before(:all) do
    @agent = run_course
  end

  it "should provide the history" do
    @agent.history.should_not be_empty
  end

  it "should provide the queue" do
    @agent.queue.should be_empty
  end

  it "should be able to restore the history" do
    agent = Agent.new
    previous_history = Set[URI('http://www.example.com')]

    agent.history = previous_history
    agent.history.should == previous_history
  end

  it "should convert new histories to an Set of URIs" do
    agent = Agent.new
    previous_history = ['http://www.example.com']
    expected_history = Set[URI('http://www.example.com')]

    agent.history = previous_history
    agent.history.should_not == previous_history
    agent.history.should == expected_history
  end

  it "should be able to restore the failures" do
    agent = Agent.new
    previous_failures = Set[URI('http://localhost/')]

    agent.failures = previous_failures
    agent.failures.should == previous_failures
  end

  it "should convert new histories to a Set of URIs" do
    agent = Agent.new
    previous_failures = ['http://localhost/']
    expected_failures = Set[URI('http://localhost/')]

    agent.failures = previous_failures
    agent.failures.should_not == previous_failures
    agent.failures.should == expected_failures
  end

  it "should be able to restore the queue" do
    agent = Agent.new
    previous_queue = [URI('http://www.example.com')]

    agent.queue = previous_queue
    agent.queue.should == previous_queue
  end

  it "should convert new queues to an Array of URIs" do
    agent = Agent.new
    previous_queue = ['http://www.example.com']
    expected_queue = [URI('http://www.example.com')]

    agent.queue = previous_queue
    agent.queue.should_not == previous_queue
    agent.queue.should == expected_queue
  end

  it "should provide a to_hash method that returns the queue and history" do
    hash = @agent.to_hash

    hash[:queue].should be_empty
    hash[:history].should_not be_empty
  end
end
