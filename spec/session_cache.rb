require 'spidr/session_cache'

require 'spec_helper'

describe SessionCache do
  describe "empty" do
    before(:all) do
      @sessions = SessionCache.new
    end

    it "should not have any active sessions" do
      @sessions.should_not be_active(URI('http://example.com/'))
    end

    it "should start new sessions on-demand" do
      @sessions[URI('http://example.com/')].should_not be_nil
    end

    after(:all) do
      @sessions.clear
    end
  end

  describe "not-empty" do
    before(:all) do
      @url = URI('http://example.com/')

      @sessions = SessionCache.new
      @sessions[@url]
    end

    it "should have active sessions" do
      @sessions.should be_active(@url)
    end

    it "should provide access to sessions" do
      @sessions[@url].should_not be_nil
    end

    it "should start new sessions on-demand" do
      url2 = URI('http://www.w3c.org/')

      @sessions[url2].should_not be_nil
    end

    it "should be able to kill sessions" do
      url2 = URI('http://www.w3c.org/')

      @sessions[url2].should_not be_nil
      @sessions.kill!(url2)
      @sessions.should_not be_active(url2)
    end

    after(:all) do
      @sessions.clear
    end
  end
end
