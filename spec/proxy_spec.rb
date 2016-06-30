require 'spec_helper'
require 'spidr/proxy'

describe Spidr::Proxy do
  describe "DEFAULT_PORT" do
    subject { described_class::DEFAULT_PORT }

    it { expect(subject).to be 8080 }
  end

  describe "#initialize" do
    it "should default port to 8080" do
      expect(subject.port).to be 8080
    end
  end
end
