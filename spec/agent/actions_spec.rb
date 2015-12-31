require 'spidr/agent'

require 'spec_helper'

describe Agent do
  describe "actions" do
    let(:url) { URI('http://spidr.rubyforge.org/') }

    it "should be able to pause spidering" do
      count = 0
      agent = Agent.host('spidr.rubyforge.org') do |spider|
        spider.every_page do |page|
          count += 1
          spider.pause! if count >= 2
        end
      end

      expect(agent).to be_paused
      expect(agent.history.length).to eq(2)
    end

    it "should be able to continue spidering after being paused" do
      agent = Agent.new do |spider|
        spider.every_page do |page|
          spider.pause!
        end
      end

      agent.enqueue(url)
      agent.continue!

      expect(agent.visited?(url)).to eq(true)
    end

    it "should allow skipping of enqueued links" do
      agent = Agent.new do |spider|
        spider.every_url do |url|
          spider.skip_link!
        end
      end

      agent.enqueue(url)

      expect(agent.queue).to be_empty
    end

    it "should allow skipping of visited pages" do
      agent = Agent.new do |spider|
        spider.every_page do |url|
          spider.skip_page!
        end
      end

      agent.visit_page(url)

      expect(agent.history).to eq(Set[url])
      expect(agent.queue).to be_empty
    end
  end
end
