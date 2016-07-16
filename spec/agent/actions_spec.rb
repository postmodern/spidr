require 'spidr/agent'

require 'spec_helper'

describe Agent do
  describe "actions" do
    let(:url) { URI('http://spidr.rubyforge.org/') }

    describe "#pause!" do
      subject do
        count = 0

        described_class.host('spidr.rubyforge.org') do |spider|
          spider.every_page do |page|
            count += 1
            spider.pause! if count >= 2
          end
        end
      end

      it "should be able to pause spidering" do
        expect(subject).to be_paused
        expect(subject.history.length).to eq(2)
      end
    end

    describe "#continue!" do
      subject do
        described_class.new do |spider|
          spider.every_page do |page|
            spider.pause!
          end
        end
      end

      before do
        subject.enqueue(url)
        subject.continue!
      end

      it "should be able to continue spidering after being paused" do
        expect(subject.visited?(url)).to eq(true)
      end
    end

    describe "#skip_link!" do
      subject do
        described_class.new do |spider|
          spider.every_url do |url|
            spider.skip_link!
          end
        end
      end

      before do
        subject.enqueue(url)
      end

      it "should allow skipping of enqueued links" do
        expect(subject.queue).to be_empty
      end
    end

    describe "#skip_page!" do
      subject do
        described_class.new do |spider|
          spider.every_page do |url|
            spider.skip_page!
          end
        end
      end

      before { subject.visit_page(url) }

      it "should allow skipping of visited pages" do
        expect(subject.history).to eq(Set[url])
        expect(subject.queue).to be_empty
      end
    end
  end
end
