require 'rspec'

shared_examples_for "includes Spidr::Settings::Timeouts" do
  describe "read_timeout" do
    context "default value" do
      it { expect(subject.read_timeout).to be_nil }
    end
  end

  describe "read_timeout=" do
    let(:value) { 5 }

    before { subject.read_timeout = value }

    it "should update read_timeout" do
      expect(subject.read_timeout).to be == value
    end

    after { subject.read_timeout = nil }
  end

  describe "open_timeout" do
    context "default value" do
      it { expect(subject.open_timeout).to be_nil }
    end
  end

  describe "open_timeout=" do
    let(:value) { 5 }

    before { subject.open_timeout = value }

    it "should update open_timeout" do
      expect(subject.open_timeout).to be == value
    end

    after { subject.open_timeout = nil }
  end

  describe "ssl_timeout" do
    context "default value" do
      it { expect(subject.ssl_timeout).to be_nil }
    end
  end

  describe "ssl_timeout=" do
    let(:value) { 5 }

    before { subject.ssl_timeout = value }

    it "should update ssl_timeout" do
      expect(subject.ssl_timeout).to be == value
    end

    after { subject.ssl_timeout = nil }
  end

  describe "continue_timeout" do
    context "default value" do
      it { expect(subject.continue_timeout).to be_nil }
    end
  end

  describe "continue_timeout=" do
    let(:value) { 5 }

    before { subject.continue_timeout = value }

    it "should update continue_timeout" do
      expect(subject.continue_timeout).to be == value
    end

    after { subject.continue_timeout = nil }
  end

  describe "keep_alive_timeout" do
    context "default value" do
      it { expect(subject.keep_alive_timeout).to be_nil }
    end
  end

  describe "keep_alive_timeout=" do
    let(:value) { 5 }

    before { subject.keep_alive_timeout = value }

    it "should update keep_alive_timeout" do
      expect(subject.keep_alive_timeout).to be == value
    end

    after { subject.keep_alive_timeout = nil }
  end
end
