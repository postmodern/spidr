require 'spidr/actions'
require 'spidr/agent'

require 'spec_helper'

describe Spidr::Actions do
  before(:all) do
    @url = URI('http://spidr.rubyforge.org/')
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
      spider.every_page do |page|
        spider.pause!
      end
    end

    agent.enqueue(@url)
    agent.continue!

    agent.visited?(@url).should == true
  end

  it "should allow skipping of enqueued links" do
    agent = Agent.new do |spider|
      spider.every_url do |url|
        spider.skip_link!
      end
    end

    agent.enqueue(@url)

    agent.queue.should be_empty
  end

  it "should allow skipping of visited pages" do
    agent = Agent.new do |spider|
      spider.every_page do |url|
        spider.skip_page!
      end
    end

    agent.visit_page(@url)

    agent.history.should == Set[@url]
    agent.queue.should be_empty
  end
end
