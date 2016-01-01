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
      expect(subject.proxy[:port]).to eq(Spidr::COMMON_PROXY_PORT)
    end

    it "should allow disabling the proxy" do
      subject.disable_proxy!

      expect(subject.proxy[:host]).to be_nil
    end
  end
end
