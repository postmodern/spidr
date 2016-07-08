require 'rspec'

shared_examples_for "includes Spidr::Settings::UserAgent" do
  describe "user_agent" do
    context "default value" do
      it { expect(subject.user_agent).to be_nil }
    end
  end

  describe "user_agent=" do
    let(:user_agent) { 'Mozilla/5.0 (iPad; U; CPU OS 3_2_1 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Mobile/7B405' }

    before do
      subject.user_agent = user_agent
    end

    it "should update the user_agent" do
      expect(subject.user_agent).to be == user_agent
    end

    after do
      subject.user_agent = nil
    end
  end
end
