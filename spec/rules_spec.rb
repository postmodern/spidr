require 'spidr/rules'

require 'spec_helper'

describe Rules do
  subject { Rules }

  it "should accept data based on acceptance data" do
    rules = subject.new(:accept => [1])

    expect(rules.accept?(1)).to eq(true)
  end

  it "should accept data based on acceptance regexps" do
    rules = subject.new(:accept => [/1/])

    expect(rules.accept?('1')).to eq(true)
  end

  it "should match non-Strings using acceptance regexps" do
    rules = subject.new(:accept => [/1/])

    expect(rules.accept?(1)).to eq(true)
  end

  it "should accept data using acceptance lambdas" do
    rules = subject.new(:accept => [lambda { |data| data > 2 }])

    expect(rules.accept?(3)).to eq(true)
  end

  it "should reject data that does not match any acceptance patterns" do
    rules = subject.new(:accept => [1, 2, 3])

    expect(rules.accept?(2)).to eq(true)
    expect(rules.accept?(4)).to eq(false)
  end

  it "should accept data that does not match any rejection patterns" do
    rules = subject.new(:reject => [1, 2, 3])

    expect(rules.accept?(2)).to eq(false)
    expect(rules.accept?(4)).to eq(true)
  end
end
