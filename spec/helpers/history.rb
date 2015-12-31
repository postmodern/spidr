module Helpers
  module History
    def visited_once?(url)
      return @agent.visited_urls.select { |visited_url|
        visited_url == url
      }.length == 1
    end

    def visited_link?(url)
      @agent.visited?(url)
    end

    def visit_failed?(url)
      @agent.failed?(url)
    end

    def should_visit_link(url)
      expect(visited_link?(url)).to eq(true)
    end

    def should_ignore_link(url)
      expect(visited_link?(url)).to eq(false)
    end

    def should_visit_once(url)
      expect(visited_once?(url)).to eq(true)
    end

    def should_fail_link(url)
      expect(visited_link?(url)).to eq(false)
      expect(visit_failed?(url)).to eq(true)
    end
  end
end
