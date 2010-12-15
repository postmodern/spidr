require 'spidr'

require 'spec_helper'

describe Spidr do
  it "should have a VERSION constant" do
    subject.const_defined?('VERSION').should == true
  end

  describe "proxy" do
    after(:all) do
      subject.disable_proxy!
    end

    it "should not have proxy settings by default" do
      subject.proxy[:host].should be_nil
    end

    it "should allow setting new proxy settings" do
      subject.proxy = {:host => 'example.com', :port => 8010}

      subject.proxy[:host].should == 'example.com'
      subject.proxy[:port].should == 8010
    end

    it "should default the :port option of new proxy settings" do
      subject.proxy = {:host => 'example.com'}

      subject.proxy[:host].should == 'example.com'
      subject.proxy[:port].should == Spidr::COMMON_PROXY_PORT
    end

    it "should allow disabling the proxy" do
      subject.disable_proxy!

      subject.proxy[:host].should be_nil
    end
  end
end
