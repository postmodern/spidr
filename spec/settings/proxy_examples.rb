require 'rspec'

shared_examples "includes Spidr::Settings::Proxy" do
  let(:proxy_host) { 'proxy.example.com' }
  let(:proxy_port) { 9999 }
  let(:proxy) { Spidr::Proxy.new(host: proxy_host, port: proxy_port) }

  describe "proxy" do
    context "when @proxy is not set" do
      before do
        subject.instance_variable_set(:"@proxy",nil)
      end

      it "should return the disabled proxy" do
        expect(subject.proxy).to be_disabled
      end

      it "should retain the default value" do
        expect(subject.proxy.object_id).to be subject.proxy.object_id
      end
    end

    context "when @proxy is set" do
      before do
        subject.instance_variable_set(:"@proxy",proxy)
      end

      it "should return the set @proxy" do
        expect(subject.proxy).to be proxy
      end
    end
  end

  describe "proxy=" do
    context "when given a Proxy object" do
      let(:proxy) { Proxy.new(host: proxy_host, port: proxy_port) }

      before { subject.proxy = proxy }

      it "should save it" do
        expect(subject.proxy).to be proxy
      end
    end

    context "when given a Hash" do
      before do
        subject.proxy = {host: proxy_host, port: proxy_port}
      end

      it "should create a new Proxy object" do
        expect(subject.proxy).to be_kind_of(Proxy)
        expect(subject.proxy[:host]).to be proxy_host
        expect(subject.proxy[:port]).to be proxy_port
      end
    end

    context "when given a URI::HTTP" do
      let(:uri) { URI::HTTP.build(host: proxy_host, port: proxy_port) }

      before { subject.proxy = uri }

      it "should create a new Proxy object based on the URI" do
        expect(subject.proxy).to be_kind_of(Proxy)
        expect(subject.proxy[:host]).to eq(proxy_host)
        expect(subject.proxy[:port]).to eq(proxy_port)
      end
    end

    context "when given a String" do
      let(:url) { "http://#{proxy_host}:#{proxy_port}" }

      before { subject.proxy = url }

      it "should parse the String as a URI and create a new Proxy object" do
        expect(subject.proxy).to be_kind_of(Proxy)
        expect(subject.proxy[:host]).to eq(proxy_host)
        expect(subject.proxy[:port]).to eq(proxy_port)
      end
    end

    context "when given nil" do
      before { subject.proxy = nil }

      it "should leave an empty proxy" do
        expect(subject.proxy).to be_kind_of(Proxy)
        expect(subject.proxy[:host]).to be_nil
      end
    end
  end

  describe "disable_proxy!" do
    before do
      subject.proxy = proxy

      subject.disable_proxy!
    end

    it "should reset the proxy" do
      expect(subject.proxy).to be_disabled
    end
  end
end
