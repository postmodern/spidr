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
      visited_link?(url).should == true
    end

    def should_ignore_link(url)
      visited_link?(url).should == false
    end

    def should_visit_once(url)
      visited_once?(url).should == true
    end

    def should_fail_link(url)
      visited_link?(url).should == false
      visit_failed?(url).should == true
    end
  end
end
