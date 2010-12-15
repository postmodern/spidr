require 'spidr/rules'

require 'spec_helper'

describe Rules do
  subject { Rules }

  it "should accept data based on acceptance data" do
    rules = subject.new(:accept => [1])

    rules.accept?(1).should == true
  end

  it "should accept data based on acceptance regexps" do
    rules = subject.new(:accept => [/1/])

    rules.accept?('1').should == true
  end

  it "should match non-Strings using acceptance regexps" do
    rules = subject.new(:accept => [/1/])

    rules.accept?(1).should == true
  end

  it "should accept data using acceptance lambdas" do
    rules = subject.new(:accept => [lambda { |data| data > 2 }])

    rules.accept?(3).should == true
  end

  it "should reject data that does not match any acceptance patterns" do
    rules = subject.new(:accept => [1, 2, 3])

    rules.accept?(2).should == true
    rules.accept?(4).should == false
  end

  it "should accept data that does not match any rejection patterns" do
    rules = subject.new(:reject => [1, 2, 3])

    rules.accept?(2).should == false
    rules.accept?(4).should == true
  end
end
