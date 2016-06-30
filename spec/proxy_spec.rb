require 'spec_helper'
require 'spidr/proxy'

describe Spidr::Proxy do
  let(:proxy_host) { 'proxy.example.com' }
  let(:proxy_port) { 9999 }
  let(:proxy_user) { 'bob' }
  let(:proxy_password) { 'secret' }

  describe "DEFAULT_PORT" do
    subject { described_class::DEFAULT_PORT }

    it { expect(subject).to be 8080 }
  end

  describe "#initialize" do
    it "should default port to 8080" do
      expect(subject.port).to be 8080
    end
  end

  describe "#enabled?" do
    context "when host is set" do
      subject { described_class.new(host: proxy_host) }

      it { expect(subject.enabled?).to be true }
    end

    context "when hist is not set" do
      it { expect(subject.enabled?).to be false }
    end
  end

  describe "#disabled?" do
    context "when hist is not set" do
      it { expect(subject.disabled?).to be true }
    end

    context "when host is set" do
      subject { described_class.new(host: proxy_host) }

      it { expect(subject.disabled?).to be false }
    end
  end
end
