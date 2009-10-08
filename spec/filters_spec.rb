require 'spidr/filters'
require 'spidr/agent'

require 'spec_helper'

describe Filters do
  it "should allow setting the acceptable schemes" do
    agent = Agent.new

    agent.schemes = [:http]
    agent.schemes.should == ['http']
  end

  it "should provide the hosts that will be visited" do
    agent = Agent.new(:hosts => ['spidr.rubyforge.org'])
    agent.visit_hosts.should == ['spidr.rubyforge.org']
  end

  it "should provide the hosts that will not be visited" do
    agent = Agent.new(:ignore_hosts => ['example.com'])
    agent.ignore_hosts.should == ['example.com']
  end

  it "should provide the ports that will be visited" do
    agent = Agent.new(:ports => [80, 443, 8000])
    agent.visit_ports.should == [80, 443, 8000]
  end

  it "should provide the ports that will not be visited" do
    agent = Agent.new(:ignore_ports => [8000, 8080])
    agent.ignore_ports.should == [8000, 8080]
  end

  it "should provide the links that will be visited" do
    agent = Agent.new(:links => ['index.php'])
    agent.visit_links.should == ['index.php']
  end

  it "should provide the links that will not be visited" do
    agent = Agent.new(:ignore_links => [/login/])
    agent.ignore_links.should == [/login/]
  end

  it "should provide the exts that will be visited" do
    agent = Agent.new(:exts => ['htm'])
    agent.visit_exts.should == ['htm']
  end

  it "should provide the exts that will not be visited" do
    agent = Agent.new(:ignore_exts => ['cfm'])
    agent.ignore_exts.should == ['cfm']
  end
end
