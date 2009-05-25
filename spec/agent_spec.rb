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

  it "should be able to pause spidering" do
    count = 0
    agent = Agent.host('spidr.rubyforge.org') do |spider|
      spider.every_page do |page|
        count += 1
        spider.pause! if count >= 2
      end
    end

    agent.should be_paused
    agent.history.length.should == 2
  end

  it "should be able to continue spidering after being paused" do
    agent = Agent.new do |spider|
      spider.enqueue('http://spidr.rubyforge.org/')
      spider.every_page do |page|
        spider.pause!
      end
    end

    agent.pause!
    agent.continue!

    agent.visited?('http://spidr.rubyforge.org/').should == true
  end
end
