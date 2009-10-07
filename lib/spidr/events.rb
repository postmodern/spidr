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
    # For every URL that the agent visits it will be passed to the
    # specified _block_.
    #
    def every_url(&block)
      @every_url_blocks << block
      return self
    end

    #
    # For every URL that the agent is unable to visit, it will be passed
    # to the specified _block_.
    #
    def every_failed_url(&block)
      @every_failed_url_blocks << block
      return self
    end

    #
    # For every URL that the agent visits and matches the specified
    # _pattern_, it will be passed to the specified _block_.
    #
    def urls_like(pattern,&block)
      @urls_like_blocks[pattern] << block
      return self
    end

    #
    # For every Page that the agent visits, pass the page to the
    # specified _block_.
    #
    def every_page(&block)
      @every_page_blocks << block
      return self
    end

    #
    # For every Page that the agent visits, pass the headers to the given
    # _block_.
    #
    def all_headers(&block)
      every_page { |page| block.call(page.headers) }
    end
  end
end
