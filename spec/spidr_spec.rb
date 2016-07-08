require 'spidr'

require 'spec_helper'

describe Spidr do
  it "should have a VERSION constant" do
    expect(subject.const_defined?('VERSION')).to eq(true)
  end

  describe "proxy" do
    after(:all) do
      Spidr.disable_proxy!
    end

    it "should not have proxy settings by default" do
      expect(subject.proxy[:host]).to be_nil
    end

    it "should allow setting new proxy settings" do
      subject.proxy = {host: 'example.com', port: 8010}

      expect(subject.proxy[:host]).to eq('example.com')
      expect(subject.proxy[:port]).to eq(8010)
    end

    it "should default the :port option of new proxy settings" do
      subject.proxy = {host: 'example.com'}

      expect(subject.proxy[:host]).to eq('example.com')
      expect(subject.proxy[:port]).to eq(Spidr::Proxy::DEFAULT_PORT)
    end

    it "should allow disabling the proxy" do
      subject.disable_proxy!

      expect(subject.proxy[:host]).to be_nil
    end
  end

  describe "#proxy=" do
    context "when given a Hash" do
      let(:host) { 'proxy.example.com' }
      let(:port) { 9999 }

      before { subject.proxy = {host: host, port: port} }

      it "should initialize the proxy based on the Hash options" do
        expect(subject.proxy[:host]).to be host
        expect(subject.proxy[:port]).to be port
      end
    end

    context "when given nil" do
      before { subject.proxy = nil }

      it "should reset the proxy to disabled" do
        expect(subject.proxy).to be_disabled
      end
    end
  end
end
