require 'spidr/agent'

require 'spec_helper'

describe Agent do
  describe "sanitizers" do
    describe "#sanitize_url" do
      let(:url) { 'http://example.com/page?q=1#fragment' }
      let(:uri) { URI(url) }

      it "should sanitize URIs" do
        clean_url = subject.sanitize_url(uri)

        expect(clean_url.host).to eq('example.com')
      end

      it "should sanitize URLs given as Strings" do
        clean_url = subject.sanitize_url(url)

        expect(clean_url.host).to eq('example.com')
      end

      it "should strip fragment components by default" do
        clean_url = subject.sanitize_url(url)

        expect(clean_url.fragment).to be_nil
      end

      it "should not strip query components by default" do
        clean_url = subject.sanitize_url(uri)

        expect(clean_url.query).to eq('q=1')
      end

      context "when strip_fragments is disabled" do
        subject { described_class.new(strip_fragments: false) }

        it "should perserve the fragment components" do
          clean_url = subject.sanitize_url(uri)

          expect(clean_url.fragment).to eq('fragment')
        end
      end

      context "when strip_query is enabled" do
        subject { described_class.new(strip_query: true) }

        it "should allow stripping of query components" do
          clean_url = subject.sanitize_url(uri)

          expect(clean_url.query).to be_nil
        end
      end
    end
  end
end
