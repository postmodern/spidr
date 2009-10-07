require 'spidr/actions'
require 'spidr/agent'

require 'spec_helper'

describe Spidr::Actions do
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

    agent.continue!

    agent.visited?('http://spidr.rubyforge.org/').should == true
  end
end
