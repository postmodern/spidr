require 'spidr/filters'
require 'spidr/events'
require 'spidr/actions'
require 'spidr/page'
require 'spidr/spidr'

require 'net/http'
require 'set'

module Spidr
  class Agent

    include Filters
    include Events
    include Actions

    # Proxy to use
    attr_accessor :proxy

    # User-Agent to use
    attr_accessor :user_agent

    # Referer to use
    attr_accessor :referer

    # Delay in between fetching pages
    attr_accessor :delay

    # History containing visited URLs
    attr_reader :history

    # List of unreachable URLs
    attr_reader :failures

    # Queue of URLs to visit
    attr_reader :queue

    #
    # Creates a new Agent object with the given _options_ and _block_.
    # If a _block_ is given, it will be passed the newly created
    # Agent object.
    #
    # _options_ may contain the following keys:
    # <tt>:proxy</tt>:: The proxy to use while spidering.
    # <tt>:user_agent</tt>:: The User-Agent string to send.
    # <tt>:referer</tt>:: The referer URL to send.
    # <tt>:delay</tt>:: Duration in seconds to pause between spidering each
    #                   link. Defaults to 0.
    # <tt>:queue</tt>:: An initial queue of URLs to visit.
    # <tt>:history</tt>:: An initial list of visited URLs.
    #
    def initialize(options={},&block)
      @proxy = (options[:proxy] || Spidr.proxy)
      @user_agent = (options[:user_agent] || Spidr.user_agent)
      @referer = options[:referer]

      @running = false
      @delay = (options[:delay] || 0)
      @history = SortedSet[]
      @failures = []
      @queue = []

      @sessions = {}

      super(options,&block)
    end

    #
    # Creates a new Agent object with the given _options_ and will begin
    # spidering at the specified _url_. If a _block_ is given it will be
    # passed the newly created Agent object, before the agent begins
    # spidering.
    #
    def self.start_at(url,options={},&block)
      self.new(options) do |spider|
        block.call(spider) if block

        spider.start_at(url)
      end
    end

    #
    # Creates a new Agent object with the given _options_ and will begin
    # spidering the specified host _name_. If a _block_ is given it will be
    # passed the newly created Agent object, before the agent begins
    # spidering.
    #
    def self.host(name,options={},&block)
      self.new(options.merge(:host => name)) do |spider|
        block.call(spider) if block

        spider.start_at("http://#{name}/")
      end
    end

    #
    # Creates a new Agent object with the given _options_ and will begin
    # spidering the host of the specified _url_. If a _block_ is given it
    # will be passed the newly created Agent object, before the agent
    # begins spidering.
    #
    def self.site(url,options={},&block)
      url = URI(url.to_s)

      return self.new(options.merge(:host => url.host)) do |spider|
        block.call(spider) if block

        spider.start_at(url)
      end
    end

    #
    # Clears the history of the agent.
    #
    def clear
      @queue.clear
      @history.clear
      @failures.clear
      return self
    end

    #
    # Start spidering at the specified _url_. If a _block_ is given, it will
    # be passed every page visited.
    #
    def start_at(url,&block)
      enqueue(url)

      return continue!(&block)
    end

    #
    # Start spidering until the queue becomes empty or the agent is
    # paused. If a _block_ is given, pass it every visited page.
    #
    def run(&block)
      @running = true

      until @queue.empty?
        begin
          visit_page(dequeue,&block)
        rescue Actions::Paused
          return self
        rescue Actions::Action
        end
      end

      @running = false

      @sessions.each_value do |sess|
        begin
          sess.finish
        rescue IOError
          nil
        end
      end

      @sessions.clear
      return self
    end

    #
    # Returns +true+ if the agent is running, returns +false+ otherwise.
    #
    def running?
      @running == true
    end

    #
    # Sets the history of links that were previously visited to the
    # specified _new_history_.
    #
    # @example
    #   agent.history = ['http://tenderlovemaking.com/2009/05/06/ann-nokogiri-130rc1-has-been-released/']
    #
    def history=(new_history)
      @history.clear

      new_history.each do |url|
        @history << url.to_s
      end

      return @history
    end

    #
    # Returns the +Array+ of visited URLs.
    #
    def visited_urls
      @history.map { |link| URI(link) }
    end

    alias visited_links history

    #
    # Return the +Array+ of hosts that were visited.
    #
    def visited_hosts
      visited_urls.map { |uri| uri.host }.uniq
    end

    #
    # Returns +true+ if the specified _url_ was visited, returns +false+
    # otherwise.
    #
    def visited?(url)
      @history.include?(url.to_s)
    end

    #
    # Returns +true+ if the specified _url_ was unable to be visited,
    # returns +false+ otherwise.
    #
    def failed?(url)
      url = URI(url) unless url.kind_of?(URI)

      return @failures.include?(url)
    end

    alias pending_urls queue

    #
    # Creates a new Page object from the specified _url_. If a _block_ is
    # given, it will be passed the newly created Page object.
    #
    def get_page(url,&block)
      host = url.host
      port = url.port

      unless url.path.empty?
        path = url.path
      else
        path = '/'
      end

      # append the URL query to the path
      path += "?#{url.query}" if url.query

      begin
        get_session(url.scheme,host,port) do |sess|
          headers = {}
          headers['User-Agent'] = @user_agent if @user_agent
          headers['Referer'] = @referer if @referer

          new_page = Page.new(url,sess.get(path,headers))

          block.call(new_page) if block
          return new_page
        end
      rescue SystemCallError, Timeout::Error, Net::HTTPBadResponse, IOError
        failed(url)
        kill_session(url.scheme,host,port)
        return nil
      end
    end

    #
    # Returns the agent represented as a Hash containing the agents
    # +history+ and +queue+ information.
    #
    def to_hash
      {:history => @history, :queue => @queue}
    end

    #
    # Sets the queue of links to visit to the specified _new_queue_.
    #
    # @example
    #   agent.queue = ['http://www.vimeo.com/', 'http://www.reddit.com/']
    #
    def queue=(new_queue)
      @queue = new_queue.map do |url|
        unless url.kind_of?(URI)
          URI(url.to_s)
        else
          url
        end
      end
    end

    #
    # Returns +true+ if the specified _url_ is queued for visiting, returns
    # +false+ otherwise.
    #
    def queued?(url)
      @queue.include?(url)
    end

    #
    # Enqueues the specified _url_ for visiting, only if it passes all the
    # agent's rules for visiting a given URL. Returns +true+ if the _url_
    # was successfully enqueued, returns +false+ otherwise.
    #
    def enqueue(url)
      link = url.to_s
      url = URI(link)

      if (!(queued?(url)) && visit?(url))
        begin
          @every_url_blocks.each { |block| block.call(url) }

          @urls_like_blocks.each do |pattern,blocks|
            if ((pattern.kind_of?(Regexp) && link =~ pattern) || pattern == link || pattern == url)
              blocks.each { |url_block| url_block.call(url) }
            end
          end
        rescue Actions::SkipLink
          return false
        rescue Actions::Action
        end

        @queue << url
        return true
      end

      return false
    end

    protected

    #
    # Returns the Net::HTTP session for the specified _host_ and _port_.
    # If a block is given, it will be passed the Net::HTTP session object.
    #
    def get_session(scheme,host,port,&block)
      key = [scheme,host,port]

      unless @sessions[key]
        session = Net::HTTP::Proxy(
          @proxy[:host],
          @proxy[:port],
          @proxy[:user],
          @proxy[:password]
        ).new(host,port)

        if scheme == 'https'
          session.use_ssl = true
          session.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        @sessions[key] = session
      end

      session = @sessions[key]
      block.call(session) if block
      return session
    end

    #
    # Destroys a Net::HTTP session for a given _scheme_, _host_, and _port_
    #
    def kill_session(scheme,host,port,&block)
      key = [scheme,host,port]
      sess = @sessions[key]

      begin 
        sess.finish
      rescue IOError
        nil
      end

      @sessions.delete(key)
      block.call if block
      return nil
    end

    #
    # Dequeues a URL that will later be visited.
    #
    def dequeue
      @queue.shift
    end

    #
    # Returns +true+ if the specified URL should be visited, returns
    # +false+ otherwise.
    #
    def visit?(url)
      (!(visited?(url)) &&
       visit_scheme?(url.scheme) &&
       visit_host?(url.host) &&
       visit_port?(url.port) &&
       visit_link?(url.to_s) &&
       visit_ext?(url.path))
    end

    #
    # Visits the spedified _url_ and enqueus it's links for visiting. If a
    # _block_ is given, it will be passed a newly created Page object
    # for the specified _url_.
    #
    def visit_page(url,&block)
      get_page(url) do |page|
        @history << page.url.to_s

        begin
          @every_page_blocks.each { |page_block| page_block.call(page) }

          block.call(page) if block
        rescue Actions::SkipPage
          return nil
        rescue Actions::Action
        end

        page.urls.each { |next_url| enqueue(next_url) }
      end
    end

    #
    # Adds the specified _url_ to the failures list.
    #
    def failed(url)
      url = URI(url.to_s) unless url.kind_of?(URI)

      @every_failed_url_blocks.each { |block| block.call(url) }
      @failures << url
      return true
    end

  end
end
