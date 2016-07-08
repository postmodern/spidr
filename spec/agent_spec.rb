require 'spidr/agent'

require 'spec_helper'
require 'settings/user_agent_examples'
require 'helpers/wsoc'

describe Agent do
  include Helpers::WSOC

  before(:all) do
    @agent = run_course
  end

  it_should_behave_like "includes Spidr::Settings::UserAgent"

  it "should provide the history" do
    expect(@agent.history).not_to be_empty
  end

  it "should provide the queue" do
    expect(@agent.queue).to be_empty
  end

  it "should be able to restore the history" do
    agent = Agent.new
    previous_history = Set[URI('http://www.example.com')]

    agent.history = previous_history
    expect(agent.history).to eq(previous_history)
  end

  it "should convert new histories to an Set of URIs" do
    agent = Agent.new
    previous_history = ['http://www.example.com']
    expected_history = Set[URI('http://www.example.com')]

    agent.history = previous_history
    expect(agent.history).not_to eq(previous_history)
    expect(agent.history).to eq(expected_history)
  end

  it "should be able to restore the failures" do
    agent = Agent.new
    previous_failures = Set[URI('http://localhost/')]

    agent.failures = previous_failures
    expect(agent.failures).to eq(previous_failures)
  end

  it "should convert new histories to a Set of URIs" do
    agent = Agent.new
    previous_failures = ['http://localhost/']
    expected_failures = Set[URI('http://localhost/')]

    agent.failures = previous_failures
    expect(agent.failures).not_to eq(previous_failures)
    expect(agent.failures).to eq(expected_failures)
  end

  it "should be able to restore the queue" do
    agent = Agent.new
    previous_queue = [URI('http://www.example.com')]

    agent.queue = previous_queue
    expect(agent.queue).to eq(previous_queue)
  end

  it "should convert new queues to an Array of URIs" do
    agent = Agent.new
    previous_queue = ['http://www.example.com']
    expected_queue = [URI('http://www.example.com')]

    agent.queue = previous_queue
    expect(agent.queue).not_to eq(previous_queue)
    expect(agent.queue).to eq(expected_queue)
  end

  it "should provide a to_hash method that returns the queue and history" do
    hash = @agent.to_hash

    expect(hash[:queue]).to be_empty
    expect(hash[:history]).not_to be_empty
  end
end
