require 'spidr/session_cache'

require 'spec_helper'
require 'settings/proxy_examples'

describe SessionCache do
  describe "#initialize" do
    let(:proxy_host) { 'proxy.example.com' }
    let(:proxy_port) { 9999 }

    let(:open_timeout)       { 1 }
    let(:ssl_timeout)        { 2 }
    let(:read_timeout)       { 3 }
    let(:continue_timeout)   { 4 }
    let(:keep_alive_timeout) { 5 }

    subject do
      described_class.new(
        proxy: {host: proxy_host, port: proxy_port},

        open_timeout:       open_timeout,
        ssl_timeout:        ssl_timeout,
        read_timeout:       read_timeout,
        continue_timeout:   continue_timeout,
        keep_alive_timeout: keep_alive_timeout,
      )
    end

    it "should set proxy" do
      expect(subject.proxy[:host]).to be == proxy_host
      expect(subject.proxy[:port]).to be == proxy_port
    end

    it "should set open_timeout" do
      expect(subject.open_timeout).to be open_timeout
    end

    it "should set ssl_timeout" do
      expect(subject.ssl_timeout).to be ssl_timeout
    end

    it "should set read_timeout" do
      expect(subject.read_timeout).to be read_timeout
    end

    it "should set continue_timeout" do
      expect(subject.continue_timeout).to be continue_timeout
    end

    it "should set keep_alive_timeout" do
      expect(subject.keep_alive_timeout).to be keep_alive_timeout
    end

    context "with no arguments" do
      before(:all) do
        Spidr.proxy = {host: 'proxy.example.com', port: 9999}

        Spidr.open_timeout       = 1
        Spidr.ssl_timeout        = 2
        Spidr.read_timeout       = 3
        Spidr.continue_timeout   = 4
        Spidr.keep_alive_timeout = 5
      end

      subject { described_class.new }

      it "should use the global proxy settings" do
        expect(subject.proxy).to be Spidr.proxy
      end

      it "should use the global open_timeout" do
        expect(subject.open_timeout).to be == Spidr.open_timeout
      end

      it "should use the global ssl_timeout" do
        expect(subject.ssl_timeout).to be == Spidr.ssl_timeout
      end

      it "should use the global read_timeout" do
        expect(subject.read_timeout).to be == Spidr.read_timeout
      end

      it "should use the global continue_timeout" do
        expect(subject.continue_timeout).to be == Spidr.continue_timeout
      end

      it "should use the global keep_alive_timeout" do
        expect(subject.keep_alive_timeout).to be == Spidr.keep_alive_timeout
      end

      before(:all) do
        Spidr.proxy = nil

        Spidr.open_timeout       = nil
        Spidr.ssl_timeout        = nil
        Spidr.read_timeout       = nil
        Spidr.continue_timeout   = nil
        Spidr.keep_alive_timeout = nil
      end
    end
  end

  it_should_behave_like "includes Spidr::Settings::Proxy"

  context "when empty" do
    before(:all) do
      @sessions = SessionCache.new
    end

    it "should not have any active sessions" do
      expect(@sessions).not_to be_active(URI('http://example.com/'))
    end

    it "should start new sessions on-demand" do
      expect(@sessions[URI('http://example.com/')]).not_to be_nil
    end

    after(:all) do
      @sessions.clear
    end
  end

  context "when not-empty" do
    before(:all) do
      @url = URI('http://example.com/')

      @sessions = SessionCache.new
      @sessions[@url]
    end

    it "should have active sessions" do
      expect(@sessions).to be_active(@url)
    end

    it "should provide access to sessions" do
      expect(@sessions[@url]).not_to be_nil
    end

    it "should start new sessions on-demand" do
      url2 = URI('http://www.w3c.org/')

      expect(@sessions[url2]).not_to be_nil
    end

    it "should be able to kill sessions" do
      url2 = URI('http://www.w3c.org/')

      expect(@sessions[url2]).not_to be_nil
      @sessions.kill!(url2)
      expect(@sessions).not_to be_active(url2)
    end

    after(:all) do
      @sessions.clear
    end
  end
end
