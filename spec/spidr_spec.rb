require 'spidr'

require 'spec_helper'

describe Spidr do
  it "should have a VERSION constant" do
    Spidr.const_defined?('VERSION').should == true
  end

  describe "proxy" do
    after(:all) do
      Spidr.disable_proxy!
    end

    it "should not have proxy settings by default" do
      Spidr.proxy[:host].should be_nil
    end

    it "should allow setting new proxy settings" do
      Spidr.proxy = {:host => 'example.com', :port => 8010}

      Spidr.proxy[:host].should == 'example.com'
      Spidr.proxy[:port].should == 8010
    end

    it "should default the :port option of new proxy settings" do
      Spidr.proxy = {:host => 'example.com'}

      Spidr.proxy[:host].should == 'example.com'
      Spidr.proxy[:port].should == Spidr::COMMON_PROXY_PORT
    end

    it "should allow disabling the proxy" do
      Spidr.disable_proxy!

      Spidr.proxy[:host].should be_nil
    end
  end
end
