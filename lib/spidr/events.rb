module Spidr
  module Events
    def initialize(options={})
      super(options)

      @every_url_blocks = []
      @every_failed_url_blocks = []
      @urls_like_blocks = Hash.new { |hash,key| hash[key] = [] }

      @every_page_blocks = []
    end

    #
    # Pass each URL from each page visited to the given block.
    #
    # @yield [url]
    #   The block will be passed every URL from every page visited.
    #
    # @yieldparam [URI::HTTP] url
    #   Each URL from each page visited.
    #
    def every_url(&block)
      @every_url_blocks << block
      return self
    end

    #
    # Pass each URL that could not be requested to the given block.
    #
    # @yield [url]
    #   The block will be passed every URL that could not be requested.
    #
    # @yieldparam [URI::HTTP] url
    #   A failed URL.
    #
    def every_failed_url(&block)
      @every_failed_url_blocks << block
      return self
    end

    #
    # Pass every URL that the agent visits, and matches a given pattern,
    # to a given block.
    #
    # @param [Regexp, String] pattern
    #   The pattern to match URLs with.
    #
    # @yield [url]
    #   The block will be passed every URL that matches the given pattern.
    #
    # @yieldparam [URI::HTTP] url
    #   A matching URL.
    #
    def urls_like(pattern,&block)
      @urls_like_blocks[pattern] << block
      return self
    end

    #
    # Pass every page that the agent visits to a given block.
    #
    # @yield [page]
    #   The block will be passed every page visited.
    #
    # @yieldparam [Page] page
    #   A visited page.
    #
    def every_page(&block)
      @every_page_blocks << block
      return self
    end

    #
    # Pass the headers from every response the agent receives to a given
    # block.
    #
    # @yield [headers]
    #   The block will be passed the headers of every response.
    #
    # @yieldparam [Hash] headers
    #   The headers from a response.
    #
    def all_headers(&block)
      every_page { |page| block.call(page.headers) }
    end
  end
end
