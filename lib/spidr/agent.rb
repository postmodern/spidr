require 'spidr/settings/user_agent'
require 'spidr/agent/sanitizers'
require 'spidr/agent/filters'
require 'spidr/agent/events'
require 'spidr/agent/actions'
require 'spidr/agent/robots'
require 'spidr/page'
require 'spidr/session_cache'
require 'spidr/cookie_jar'
require 'spidr/auth_store'
require 'spidr/spidr'

require 'openssl'
require 'net/http'
require 'set'

module Spidr
  class Agent

    include Settings::UserAgent

    # HTTP Host Header to use
    #
    # @return [String]
    attr_accessor :host_header

    # HTTP Host Headers to use for specific hosts
    #
    # @return [Hash{String,Regexp => String}]
    attr_reader :host_headers

    # HTTP Headers to use for every request
    #
    # @return [Hash{String => String}]
    #
    # @since 0.6.0
    attr_reader :default_headers

    # HTTP Authentication credentials
    #
    # @return [AuthStore]
    attr_accessor :authorized

    # Referer to use
    #
    # @return [String]
    attr_accessor :referer

    # Delay in between fetching pages
    #
    # @return [Integer]
    attr_accessor :delay

    # History containing visited URLs
    #
    # @return [Set<URI::HTTP>]
    attr_reader :history

    # List of unreachable URLs
    #
    # @return [Set<URI::HTTP>]
    attr_reader :failures

    # Queue of URLs to visit
    #
    # @return [Array<URI::HTTP>]
    attr_reader :queue

    # The session cache
    #
    # @return [SessionCache]
    #
    # @since 0.6.0
    attr_reader :sessions

    # Cached cookies
    #
    # @return [CookieJar]
    attr_reader :cookies

    # Maximum number of pages to visit.
    #
    # @return [Integer]
    attr_reader :limit

    # Maximum depth
    #
    # @return [Integer]
    attr_reader :max_depth

    # The visited URLs and their depth within a site
    #
    # @return [Hash{URI::HTTP => Integer}]
    attr_reader :levels

    #
    # Creates a new Agent object.
    #
    # @param [Integer, nil] open_timeout
    #   Optional open timeout.
    #
    # @param [Integer, nil] read_timeout
    #   Optional read timeout.
    #
    # @param [Integer, nil] ssl_timeout
    #   Optional ssl timeout.
    #
    # @param [Integer, nil] continue_timeout
    #   Optional continue timeout.
    #
    # @param [Integer, nil] keep_alive_timeout
    #   Optional keep_alive timeout.
    #
    # @param [Spidr::Proxy, Hash, URI::HTTP, String, nil] proxy
    #   The proxy information to use.
    #
    # @option proxy [String] :host
    #   The host the proxy is running on.
    #
    # @option proxy [Integer] :port (8080)
    #   The port the proxy is running on.
    #
    # @option proxy [String, nil] :user
    #   The user to authenticate as with the proxy.
    #
    # @option proxy [String, nil] :password
    #   The password to authenticate with.
    #
    # @param [Hash{String => String}] default_headers
    #   Default headers to set for every request.
    #
    # @param [String, nil] host_header
    #   The HTTP Host header to use with each request.
    #
    # @param [Hash{String,Regexp => String}] host_headers
    #   The HTTP Host headers to use for specific hosts.
    #
    # @param [String, nil] user_agent
    #   The User-Agent string to send with each requests.
    #
    # @param [String, nil] referer
    #   The Referer URL to send with each request.
    #
    # @param [Integer] delay
    #   The number of seconds to pause between each request.
    #
    # @param [Set, Array, nil] queue
    #   The initial queue of URLs to visit.
    #
    # @param [Set, Array, nil] history
    #   The initial list of visited URLs.
    #
    # @param [Integer, nil] limit
    #   The maximum number of pages to visit.
    #
    # @param [Integer, nil] max_depth
    #   The maximum link depth to follow.
    #
    # @param [Boolean] robots
    #   Specifies whether `robots.txt` should be honored.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   for further configuration.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    def initialize(# header keyword arguments
                   host_header:        nil,
                   host_headers:       {},
                   default_headers:    {},
                   user_agent:         Spidr.user_agent,
                   referer:            nil,
                   # session cache keyword arguments
                   proxy:              Spidr.proxy,
                   open_timeout:       Spidr.open_timeout,
                   ssl_timeout:        Spidr.ssl_timeout,
                   read_timeout:       Spidr.read_timeout,
                   continue_timeout:   Spidr.continue_timeout,
                   keep_alive_timeout: Spidr.keep_alive_timeout,
                   # spidering controls keyword arguments
                   delay:     0,
                   limit:     nil,
                   max_depth: nil,
                   # history keyword arguments
                   queue:   nil,
                   history: nil,
                   # sanitizer keyword arguments
                   strip_fragments: true,
                   strip_query:     false,
                   # filtering keyword arguments
                   schemes:      self.class.default_schemes,
                   host:         nil,
                   hosts:        nil,
                   ignore_hosts: nil,
                   ports:        nil,
                   ignore_ports: nil,
                   links:        nil,
                   ignore_links: nil,
                   urls:         nil,
                   ignore_urls:  nil,
                   exts:         nil,
                   ignore_exts:  nil,
                   # robots keyword arguments
                   robots:       Spidr.robots?)
      @host_header  = host_header
      @host_headers = host_headers

      @default_headers = default_headers

      @user_agent = user_agent
      @referer    = referer

      @sessions   = SessionCache.new(
        proxy:              proxy,
        open_timeout:       open_timeout,
        ssl_timeout:        ssl_timeout,
        read_timeout:       read_timeout,
        continue_timeout:   continue_timeout,
        keep_alive_timeout: keep_alive_timeout
      )
      @cookies    = CookieJar.new
      @authorized = AuthStore.new

      @running  = false
      @delay    = delay
      @history  = Set[]
      @failures = Set[]
      @queue    = []

      @limit     = limit
      @levels    = Hash.new(0)
      @max_depth = max_depth

      self.queue   = queue   if queue
      self.history = history if history

      initialize_sanitizers(
        strip_fragments: strip_fragments,
        strip_query:     strip_query
      )

      initialize_filters(
        schemes:      schemes,
        host:         host,
        hosts:        hosts,
        ignore_hosts: ignore_hosts,
        ports:        ports,
        ignore_ports: ignore_ports,
        links:        links,
        ignore_links: ignore_links,
        urls:         urls,
        ignore_urls:  ignore_urls,
        exts:         exts,
        ignore_exts:  ignore_exts
      )
      initialize_actions
      initialize_events

      initialize_robots if robots

      yield self if block_given?
    end

    #
    # Creates a new agent and begin spidering at the given URL.
    #
    # @param [URI::HTTP, String] url
    #   The URL to start spidering at.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments. See {Agent#initialize}.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   before it begins spidering.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    # @return [Agent]
    #   The created agent object.
    #
    # @see #initialize
    # @see #start_at
    #
    def self.start_at(url,**kwargs,&block)
      agent = new(**kwargs,&block)
      agent.start_at(url)
      return agent
    end

    #
    # Creates a new agent and spiders the web-site located at the given URL.
    #
    # @param [URI::HTTP, String] url
    #   The web-site to spider.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments. See {Agent#initialize}.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   before it begins spidering.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    # @return [Agent]
    #   The created agent object.
    #
    # @see #initialize
    #
    def self.site(url,**kwargs,&block)
      url = URI(url)

      agent = new(host: url.host, **kwargs, &block)
      agent.start_at(url)
      return agent
    end

    #
    # Creates a new agent and spiders the given host.
    #
    # @param [String] name
    #   The host-name to spider.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments. See {Agent#initialize}.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   before it begins spidering.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    # @return [Agent]
    #   The created agent object.
    #
    # @see #initialize
    #
    def self.host(name,**kwargs,&block)
      agent = new(host: name, **kwargs, &block)
      agent.start_at(URI::HTTP.build(host: name, path: '/'))
      return agent
    end

    #
    # Creates a new agent and spiders the entire domain.
    #
    # @param [String] name
    #   The top-level domain to spider.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments. See {Agent#initialize}.
    #
    # @yield [agent]
    #   If a block is given, it will be passed the newly created agent
    #   before it begins spidering.
    #
    # @yieldparam [Agent] agent
    #   The newly created agent.
    #
    # @return [Agent]
    #   The created agent object.
    #
    # @see #initialize
    #
    # @since 0.7.0
    #
    def self.domain(name,**kwargs,&block)
      agent = new(host: /(^|\.)#{Regexp.escape(name)}$/, **kwargs, &block)
      agent.start_at(URI::HTTP.build(host: name, path: '/'))
      return agent
    end

    #
    # The proxy information the agent uses.
    #
    # @return [Proxy]
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
    # @param [Proxy, Hash, URI::HTTP, String, nil] new_proxy
    #   The new proxy information.
    #
    # @return [Proxy]
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

      until (@queue.empty? || paused? || limit_reached?)
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
        @history << URI(url)
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
      @history.map(&:to_s)
    end

    #
    # Specifies all hosts that were visited.
    #
    # @return [Array<String>]
    #   The hosts which have been visited.
    #
    def visited_hosts
      visited_urls.map(&:host).uniq
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
      @history.include?(URI(url))
    end

    #
    # Sets the list of failed URLs.
    #
    # @param [#each] new_failures
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
        @failures << URI(url)
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
      @failures.include?(URI(url))
    end

    alias pending_urls queue

    #
    # Sets the queue of URLs to visit.
    #
    # @param [#each] new_queue
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
        @queue << URI(url)
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

      if (!queued?(url) && visit?(url))
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
      url = URI(url)

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
      url = URI(url)

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
      {history: @history, queue: @queue}
    end

    protected

    #
    # Prepares request headers for the given URL.
    #
    # @param [URI::HTTP] url
    #   The URL to prepare the request headers for.
    #
    # @return [Hash{String => String}]
    #   The prepared headers.
    #
    # @since 0.6.0
    #
    def prepare_request_headers(url)
      # set any additional HTTP headers
      headers = @default_headers.dup

      unless @host_headers.empty?
        @host_headers.each do |name,header|
          if url.host.match(name)
            headers['Host'] = header
            break
          end
        end
      end

      headers['Host']     ||= @host_header if @host_header
      headers['User-Agent'] = @user_agent if @user_agent
      headers['Referer']    = @referer if @referer

      if (authorization = @authorized.for_url(url))
        headers['Authorization'] = "Basic #{authorization}"
      end

      if (header_cookies = @cookies.for_host(url.host))
        headers['Cookie'] = header_cookies
      end

      return headers
    end

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
      path = unless url.path.empty?
               url.path
             else
               '/'
             end

      # append the URL query to the path
      path += "?#{url.query}" if url.query

      headers = prepare_request_headers(url)

      begin
        sleep(@delay) if @delay > 0

        yield @sessions[url], path, headers
      rescue SystemCallError,
             Timeout::Error,
             SocketError,
             IOError,
             OpenSSL::SSL::SSLError,
             Net::HTTPBadResponse,
             Zlib::Error

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
    # Determines if the maximum limit has been reached.
    #
    # @return [Boolean]
    #
    # @since 0.6.0
    #
    def limit_reached?
      @limit && @history.length >= @limit
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
      !visited?(url) &&
       visit_scheme?(url.scheme) &&
       visit_host?(url.host) &&
       visit_port?(url.port) &&
       visit_link?(url.to_s) &&
       visit_url?(url) &&
       visit_ext?(url.path) &&
       robot_allowed?(url.to_s)
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
