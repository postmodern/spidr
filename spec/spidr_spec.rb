require 'spidr'

require 'spec_helper'

describe Spidr do
  it "should have a VERSION constant" do
    Spidr.const_defined?('VERSION').should == true
  end
end
