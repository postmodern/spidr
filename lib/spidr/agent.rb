require 'spidr/sanitizers'
require 'spidr/filters'
require 'spidr/events'
require 'spidr/actions'
require 'spidr/page'
require 'spidr/session_cache'
require 'spidr/cookie_jar'
require 'spidr/auth_store'
require 'spidr/spidr'

require 'net/http'
require 'set'

module Spidr
  class Agent

    include Sanitizers
    include Filters
    include Events
    include Actions

    # HTTP Host Header to use
    attr_accessor :host_header

    # HTTP Host Headers to use for specific hosts
    attr_reader :host_headers

    # User-Agent to use
    attr_accessor :user_agent

    # HTTP Authentication credentials
    attr_accessor :authorized

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

    # Cached cookies
    attr_reader :cookies
    
    # Maximum depth
    attr_reader :max_depth

    # The visited URLs and their depth within a site
    attr_reader :levels

    #
    # Creates a new Agent object.
    #
    # @param [Hash] options
    #   Additional options
    #
    # @option options [Hash] :proxy (Spidr.proxy)
    #   The proxy information to use.
    #
    # @option :proxy [String] :host
    #   The host the proxy is running on.
    #
    # @option :proxy [Integer] :port
    #   The port the proxy is running on.
    #
    # @option :proxy [String] :user
    #   The user to authenticate as with the proxy.
    #
    # @option :proxy [String] :password
    #   The password to authenticate with.
    #
    # @option options [String] :host_header
    #   The HTTP Host header to use with each request.
    #
    # @option options [Hash{String,Regexp => String}] :host_headers
    #   The HTTP Host headers to use for specific hosts.
    #
    # @option options [String] :user_agent (Spidr.user_agent)
    #   The User-Agent string to send with each requests.
    #
    # @option options [String] :referer
    #   The Referer URL to send with each request.
    #
    # @option options [Integer] :delay (0)
    #   The number of seconds to pause between each request.
    #
    # @option options [Set, Array] :queue
    #   The initial queue of URLs to visit.
    #
    # @option options [Set, Array] :history
    #   The initial list of visited URLs.
    #
    # @option options [Integer] :max_depth
    #   The maximum link depth to follow.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   for further configuration.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    def initialize(options={})
      @host_header = options[:host_header]
      @host_headers = {}

      if options[:host_headers]
        @host_headers.merge!(options[:host_headers])
      end

      @user_agent = (options[:user_agent] || Spidr.user_agent)
      @referer = options[:referer]

      @sessions = SessionCache.new(options[:proxy] || Spidr.proxy)
      @cookies = CookieJar.new
      @authorized = AuthStore.new

      @running = false
      @delay = (options[:delay] || 0)
      @history = Set[]
      @failures = Set[]
      @queue = []

      @levels = Hash.new(0)
      @max_depth = options[:max_depth]

      initialize_sanitizers(options)
      initialize_filters(options)
      initialize_actions(options)
      initialize_events(options)

      yield self if block_given?
    end

    #
    # Creates a new agent and begin spidering at the given URL.
    #
    # @param [URI::HTTP, String] url
    #   The URL to start spidering at.
    #
    # @param [Hash] options
    #   Additional options. See {Agent#initialize}.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   before it begins spidering.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    def self.start_at(url,options={},&block)
      agent = new(options,&block)
      agent.start_at(url)
    end

    #
    # Creates a new agent and spiders the web-site located at the given URL.
    #
    # @param [URI::HTTP, String] url
    #   The web-site to spider.
    #
    # @param [Hash] options
    #   Additional options. See {Agent#initialize}.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   before it begins spidering.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    def self.site(url,options={},&block)
      url = URI(url.to_s) unless url.kind_of?(URI)

      agent = new(options.merge(:host => url.host),&block)
      agent.start_at(url)
    end

    #
    # Creates a new agent and spiders the given host.
    #
    # @param [String]
    #   The host-name to spider.
    #
    # @param [Hash] options
    #   Additional options. See {Agent#initialize}.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   before it begins spidering.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    def self.host(name,options={},&block)
      site(URI::HTTP.build(:host => name, :path => '/'),options,&block)
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
    # Start spidering at a given URL.
    #
    # @param [URI::HTTP, String] url
    #   The URL to start spidering at.
    #
    # @yield [page]
    #   If a block is given, it will be passed every page visited.
    #
    # @yieldparam [Page] page
    #   A page which has been visited.
    #
    def start_at(url,&block)
      enqueue(url)

      return run(&block)
    end

    #
    # Start spidering until the queue becomes empty or the agent is
    # paused.
    #
    # @yield [page]
    #   If a block is given, it will be passed every page visited.
    #
    # @yieldparam [Page] page
    #   A page which has been visited.
    #
    def run(&block)
      @running = true

      until (@queue.empty? || paused?)
        begin
          visit_page(dequeue,&block)
        rescue Actions::Paused
          return self
        rescue Actions::Action
        end
      end

      @running = false

      @sessions.clear
      return self
    end

    #
    # Determines if the agent is running.
    #
    # @return [Boolean]
    #   Specifies whether the agent is running or stopped.
    #
    def running?
      @running == true
    end

    #
    # The proxy information the agent uses.
    #
    # @return [Hash]
    #   The proxy information.
    #
    # @see SessionCache#proxy
    #
    # @since 0.2.2
    #
    def proxy
      @sessions.proxy
    end

    #
    # Sets the proxy information that the agent uses.
    #
    # @param [Hash] new_proxy
    #   The new proxy information.
    #
    # @return [Hash]
    #   The new proxy information.
    #
    # @see SessionCache#proxy=
    #
    # @since 0.2.2
    #
    def proxy=(new_proxy)
      @sessions.proxy = new_proxy
    end

    #
    # Sets the history of URLs that were previously visited.
    #
    # @param [#each] new_history
    #   A list of URLs to populate the history with.
    #
    # @return [Set<URI::HTTP>]
    #   The history of the agent.
    #
    # @example
    #   agent.history = ['http://tenderlovemaking.com/2009/05/06/ann-nokogiri-130rc1-has-been-released/']
    #
    def history=(new_history)
      @history.clear

      new_history.each do |url|
        @history << unless url.kind_of?(URI)
                      URI(url.to_s)
                    else
                      url
                    end
      end

      return @history
    end

    alias visited_urls history

    #
    # Specifies the links which have been visited.
    #
    # @return [Array<String>]
    #   The links which have been visited.
    #
    def visited_links
      @history.map { |url| url.to_s }
    end

    #
    # Specifies all hosts that were visited.
    #
    # @return [Array<String>]
    #   The hosts which have been visited.
    #
    def visited_hosts
      visited_urls.map { |uri| uri.host }.uniq
    end

    #
    # Determines whether a URL was visited or not.
    #
    # @param [URI::HTTP, String] url
    #   The URL to search for.
    #
    # @return [Boolean]
    #   Specifies whether a URL was visited.
    #
    def visited?(url)
      url = URI(url.to_s) unless url.kind_of?(URI)

      return @history.include?(url)
    end

    #
    # Sets the list of failed URLs.
    #
    # @param [#each]
    #   The new list of failed URLs.
    #
    # @return [Array<URI::HTTP>]
    #   The list of failed URLs.
    #
    # @example
    #   agent.failures = ['http://localhost/']
    #
    def failures=(new_failures)
      @failures.clear

      new_failures.each do |url|
        @failures << unless url.kind_of?(URI)
                    URI(url.to_s)
                  else
                    url
                  end
      end

      return @failures
    end

    #
    # Determines whether a given URL could not be visited.
    #
    # @param [URI::HTTP, String] url
    #   The URL to check for failures.
    #
    # @return [Boolean]
    #   Specifies whether the given URL was unable to be visited.
    #
    def failed?(url)
      url = URI(url.to_s) unless url.kind_of?(URI)

      return @failures.include?(url)
    end

    alias pending_urls queue

    #
    # Sets the queue of URLs to visit.
    #
    # @param [#each]
    #   The new list of URLs to visit.
    #
    # @return [Array<URI::HTTP>]
    #   The list of URLs to visit.
    #
    # @example
    #   agent.queue = ['http://www.vimeo.com/', 'http://www.reddit.com/']
    #
    def queue=(new_queue)
      @queue.clear

      new_queue.each do |url|
        @queue << unless url.kind_of?(URI)
                    URI(url.to_s)
                  else
                    url
                  end
      end

      return @queue
    end

    #
    # Determines whether a given URL has been enqueued.
    #
    # @param [URI::HTTP] url
    #   The URL to search for in the queue.
    #
    # @return [Boolean]
    #   Specifies whether the given URL has been queued for visiting.
    #
    def queued?(url)
      @queue.include?(url)
    end

    #
    # Enqueues a given URL for visiting, only if it passes all of the
    # agent's rules for visiting a given URL.
    #
    # @param [URI::HTTP, String] url
    #   The URL to enqueue for visiting.
    #
    # @return [Boolean]
    #   Specifies whether the URL was enqueued, or ignored.
    #
    def enqueue(url,level=0)
      url = sanitize_url(url)

      if (!(queued?(url)) && visit?(url))
        link = url.to_s

        begin
          @every_url_blocks.each { |url_block| url_block.call(url) }

          @every_url_like_blocks.each do |pattern,url_blocks|
            match = case pattern
                    when Regexp
                      link =~ pattern
                    else
                      (pattern == link) || (pattern == url)
                    end

            if match
              url_blocks.each { |url_block| url_block.call(url) }
            end
          end
        rescue Actions::Paused => action
          raise(action)
        rescue Actions::SkipLink
          return false
        rescue Actions::Action
        end
        
        @queue << url
        @levels[url] = level
        return true
      end

      return false
    end
    
    #
    # Requests and creates a new Page object from a given URL.
    #
    # @param [URI::HTTP] url
    #   The URL to request.
    #
    # @yield [page]
    #   If a block is given, it will be passed the page that represents the
    #   response.
    #
    # @yieldparam [Page] page
    #   The page for the response.
    #
    # @return [Page, nil]
    #   The page for the response, or `nil` if the request failed.
    #
    def get_page(url)
      url = URI(url.to_s)

      prepare_request(url) do |session,path,headers|
        new_page = Page.new(url,session.get(path,headers))

        # save any new cookies
        @cookies.from_page(new_page)

        yield new_page if block_given?
        return new_page
      end
    end

    #
    # Posts supplied form data and creates a new Page object from a given URL.
    #
    # @param [URI::HTTP] url
    #   The URL to request.
    #
    # @param [String] post_data
    #   Form option data.
    #
    # @yield [page]
    #   If a block is given, it will be passed the page that represents the
    #   response.
    #
    # @yieldparam [Page] page
    #   The page for the response.
    #
    # @return [Page, nil]
    #   The page for the response, or `nil` if the request failed.
    #
    # @since 0.2.2
    #
    def post_page(url,post_data='')
      url = URI(url.to_s)

      prepare_request(url) do |session,path,headers|
        new_page = Page.new(url,session.post(path,post_data,headers))

        # save any new cookies
        @cookies.from_page(new_page)

        yield new_page if block_given?
        return new_page
      end
    end

    #
    # Visits a given URL, and enqueus the links recovered from the URL
    # to be visited later.
    #
    # @param [URI::HTTP, String] url
    #   The URL to visit.
    #
    # @yield [page]
    #   If a block is given, it will be passed the page which was visited.
    #
    # @yieldparam [Page] page
    #   The page which was visited.
    #
    # @return [Page, nil]
    #   The page that was visited. If `nil` is returned, either the request
    #   for the page failed, or the page was skipped.
    #
    def visit_page(url)
      url = sanitize_url(url)

      get_page(url) do |page|
        @history << page.url

        begin
          @every_page_blocks.each { |page_block| page_block.call(page) }

          yield page if block_given?
        rescue Actions::Paused => action
          raise(action)
        rescue Actions::SkipPage
          return nil
        rescue Actions::Action
        end

        page.each_url do |next_url|
          begin
            @every_link_blocks.each do |link_block|
              link_block.call(page.url,next_url)
            end
          rescue Actions::Paused => action
            raise(action)
          rescue Actions::SkipLink
            next
          rescue Actions::Action
          end

          if (@max_depth.nil? || @max_depth > @levels[url])
            enqueue(next_url,@levels[url] + 1)
          end
        end
      end
    end

    #
    # Converts the agent into a Hash.
    #
    # @return [Hash]
    #   The agent represented as a Hash containing the `history` and
    #   the `queue` of the agent.
    #
    def to_hash
      {:history => @history, :queue => @queue}
    end

    protected

    #
    # Normalizes the request path and grabs a session to handle page
    # get and post requests.
    #
    # @param [URI::HTTP] url
    #   The URL to request.
    #
    # @yield [request]
    #   A block whose purpose is to make a page request.
    #
    # @yieldparam [Net::HTTP] session
    #   An HTTP session object.
    #
    # @yieldparam [String] path
    #   Normalized URL string.
    #
    # @yieldparam [Hash] headers
    #   A Hash of request header options.
    #
    # @since 0.2.2
    #
    def prepare_request(url,&block)
      host = url.host
      port = url.port

      unless url.path.empty?
        path = url.path
      else
        path = '/'
      end

      # append the URL query to the path
      path += "?#{url.query}" if url.query

      # set any additional HTTP headers
      headers = {}

      unless @host_headers.empty?
        @host_headers.each do |name,header|
          if host.match(name)
            headers['Host'] = header
            break
          end
        end
      end

      headers['Host'] ||= @host_header if @host_header
      headers['User-Agent'] = @user_agent if @user_agent
      headers['Referer'] = @referer if @referer

      if (authorization = @authorized.for_url(url))
        headers['Authorization'] = "Basic #{authorization}"
      end

      if (header_cookies = @cookies.for_host(url.host))
        headers['Cookie'] = header_cookies
      end

      begin
        sleep(@delay) if @delay > 0

        yield @sessions[url], path, headers
      rescue SystemCallError,
             Timeout::Error,
             SocketError,
             Net::HTTPBadResponse,
             IOError

        @sessions.kill!(url)

        failed(url)
        return nil
      end
    end

    #
    # Dequeues a URL that will later be visited.
    #
    # @return [URI::HTTP]
    #   The URL that was at the front of the queue.
    #
    def dequeue
      @queue.shift
    end

    #
    # Determines if a given URL should be visited.
    #
    # @param [URI::HTTP] url
    #   The URL in question.
    #
    # @return [Boolean]
    #   Specifies whether the given URL should be visited.
    #
    def visit?(url)
      !(visited?(url)) &&
       visit_scheme?(url.scheme) &&
       visit_host?(url.host) &&
       visit_port?(url.port) &&
       visit_link?(url.to_s) &&
       visit_url?(url) &&
       visit_ext?(url.path)
    end

    #
    # Adds a given URL to the failures list.
    #
    # @param [URI::HTTP] url
    #   The URL to add to the failures list.
    #
    def failed(url)
      @failures << url
      @every_failed_url_blocks.each { |fail_block| fail_block.call(url) }
      return true
    end

  end
end
