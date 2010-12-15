require 'spidr/sanitizers'
require 'spidr/agent'

require 'spec_helper'

describe Sanitizers do
  describe "sanitize_url" do
    let(:url) { 'http://host.com' }
    before(:all) { @agent = Agent.new }

    it "should sanitize URLs" do
      agent = Agent.new
      clean_url = agent.sanitize_url(URI(url))

      clean_url.host.should == 'host.com'
    end

    it "should sanitize URLs given as Strings" do
      agent = Agent.new
      clean_url = agent.sanitize_url(url)

      clean_url.host.should == 'host.com'
    end
  end

  describe "strip_fragments" do
    let(:url) { URI("http://host.com/page#lol") }

    it "should strip fragment components by default" do
      agent = Agent.new
      clean_url = agent.sanitize_url(url)

      clean_url.fragment.should be_nil
    end

    it "should allow perserving fragment components" do
      agent = Agent.new(:strip_fragments => false)
      clean_url = agent.sanitize_url(url)

      clean_url.fragment.should == 'lol'
    end
  end

  describe "strip_query" do
    let(:url) { URI("http://host.com/page?x=1") }

    it "should not strip query components by default" do
      agent = Agent.new
      clean_url = agent.sanitize_url(url)

      clean_url.query.should == 'x=1'
    end

    it "should allow stripping of query components" do
      agent = Agent.new(:strip_query => true)
      clean_url = agent.sanitize_url(url)

      clean_url.query.should be_nil
    end
  end
end
