require 'spidr/agent'

require 'spec_helper'
require 'settings/user_agent_examples'

describe Agent do
  it_should_behave_like "includes Spidr::Settings::UserAgent"

  describe "#initialize" do
    it "should not be running" do
      expect(subject).to_not be_running
    end

    it "should default :delay to 0" do
      expect(subject.delay).to be 0
    end

    it "should initialize #history" do
      expect(subject.history).to be_empty
    end

    it "should initialize #failures" do
      expect(subject.failures).to be_empty
    end

    it "should initialize #queue" do
      expect(subject.queue).to be_empty
    end

    it "should initialize the #session_cache" do
      expect(subject.sessions).to be_kind_of(SessionCache)
    end

    it "should initialize the #cookie_jar" do
      expect(subject.cookies).to be_kind_of(CookieJar)
    end

    it "should initialize the #auth_store" do
      expect(subject.authorized).to be_kind_of(AuthStore)
    end
  end

  describe "#history=" do
    let(:previous_history) { Set[URI('http://example.com')] }

    before { subject.history = previous_history }

    it "should be able to restore the history" do
      expect(subject.history).to eq(previous_history)
    end

    context "when given an Array of URIs" do
      let(:previous_history)  { [URI('http://example.com')] }
      let(:converted_history) { Set.new(previous_history) }

      it "should convert the Array to a Set" do
        expect(subject.history).to eq(converted_history)
      end
    end

    context "when given an Set of Strings" do
      let(:previous_history)  { Set['http://example.com'] }
      let(:converted_history) do
        previous_history.map { |url| URI(url) }.to_set
      end

      it "should convert the Strings to URIs" do
        expect(subject.history).to eq(converted_history)
      end
    end
  end

  describe "#failures=" do
    let(:previous_failures) { Set[URI('http://example.com')] }

    before { subject.failures = previous_failures }

    it "should be able to restore the failures" do
      expect(subject.failures).to eq(previous_failures)
    end

    context "when given an Array of URIs" do
      let(:previous_failures)  { [URI('http://example.com')] }
      let(:converted_failures) { Set.new(previous_failures) }

      it "should convert the Array to a Set" do
        expect(subject.failures).to eq(converted_failures)
      end
    end

    context "when given an Set of Strings" do
      let(:previous_failures)  { Set['http://example.com'] }
      let(:converted_failures) do
        previous_failures.map { |url| URI(url) }.to_set
      end

      it "should convert the Strings to URIs" do
        expect(subject.failures).to eq(converted_failures)
      end
    end
  end

  describe "#queue=" do
    let(:previous_queue) { [URI('http://example.com')] }

    before { subject.queue = previous_queue }

    it "should be able to restore the queue" do
      expect(subject.queue).to eq(previous_queue)
    end

    context "when given an Set of URIs" do
      let(:previous_queue)  { Set[URI('http://example.com')] }
      let(:converted_queue) { previous_queue.to_a }

      it "should convert the Set to an Array" do
        expect(subject.queue).to eq(converted_queue)
      end
    end

    context "when given an Array of Strings" do
      let(:previous_queue)  { Set['http://example.com'] }
      let(:converted_queue) { previous_queue.map { |url| URI(url) } }

      it "should convert the Strings to URIs" do
        expect(subject.queue).to eq(converted_queue)
      end
    end
  end

  describe "#to_hash" do
    let(:queue)   { [URI("http://example.com/link")] }
    let(:history) { Set[URI("http://example.com/")]  }

    subject do
      described_class.new do |agent|
        agent.queue   = queue
        agent.history = history
      end
    end

    it "should return the queue and history" do
      expect(subject.to_hash).to be == {
        history: history,
        queue:   queue
      }
    end
  end
end
