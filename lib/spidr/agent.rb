require 'spidr/rules'
require 'spidr/page'
require 'spidr/spidr'

require 'net/http'

module Spidr
  class Agent

    # URL schemes to visit
    SCHEMES = ['http', 'https']

    # Proxy to use
    attr_accessor :proxy

    # User-Agent to use
    attr_accessor :user_agent

    # Referer to use
    attr_accessor :referer

    # Delay in between fetching pages
    attr_accessor :delay

    # History containing visited URLs
    attr_accessor :history

    # List of unreachable URLs
    attr_reader :failed

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
    # <tt>:host</tt>:: The host-name to visit.
    # <tt>:hosts</tt>:: An +Array+ of host patterns to visit.
    # <tt>:ignore_hosts</tt>:: An +Array+ of host patterns to not visit.
    # <tt>:ports</tt>:: An +Array+ of port patterns to visit.
    # <tt>:ignore_ports</tt>:: An +Array+ of port patterns to not visit.
    # <tt>:links</tt>:: An +Array+ of link patterns to visit.
    # <tt>:ignore_links</tt>:: An +Array+ of link patterns to not visit.
    # <tt>:exts</tt>:: An +Array+ of File extension patterns to visit.
    # <tt>:ignore_exts</tt>:: An +Array+ of File extension patterns to not
    #                         visit.
    #
    def initialize(options={},&block)
      @proxy = (options[:proxy] || Spidr.proxy)
      @user_agent = (options[:user_agent] || Spidr.user_agent)
      @referer = options[:referer]

      @host_rules = Rules.new(
        :accept => options[:hosts],
        :reject => options[:ignore_hosts]
      )
      @port_rules = Rules.new(
        :accept => options[:ports],
        :reject => options[:ignore_ports]
      )
      @link_rules = Rules.new(
        :accept => options[:links],
        :reject => options[:ignore_links]
      )
      @ext_rules = Rules.new(
        :accept => options[:exts],
        :reject => options[:ignore_exts]
      )

      @every_url_blocks = []
      @urls_like_blocks = Hash.new { |hash,key| hash[key] = [] }

      @every_page_blocks = []

      @delay = (options[:delay] || 0)
      @history = []
      @queue = []
      @failed = []

      if options[:host]
        visit_hosts_like(options[:host])
      end

      block.call(self) if block
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
    # Returns the +Array+ of host patterns to visit.
    #
    def visit_hosts
      @host_rules.accept
    end

    #
    # Adds the given _pattern_ to the visit_hosts. If a _block_ is given,
    # it will be added to the visit_hosts.
    #
    def visit_hosts_like(pattern=nil,&block)
      if pattern
        visit_hosts << pattern
      elsif block
        visit_hosts << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL host patterns to not visit.
    #
    def ignore_hosts
      @host_rules.reject
    end

    #
    # Adds the given _pattern_ to the ignore_hosts. If a _block_ is given,
    # it will be added to the ignore_hosts.
    #
    def ignore_hosts_like(pattern=nil,&block)
      if pattern
        ignore_hosts << pattern
      elsif block
        ignore_hosts << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL port patterns to visit.
    #
    def visit_ports
      @port_rules.accept
    end

    #
    # Adds the given _pattern_ to the visit_ports. If a _block_ is given,
    # it will be added to the visit_ports.
    #
    def visit_ports_like(pattern=nil,&block)
      if pattern
        visit_ports << pattern
      elsif block
        visit_ports << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL port patterns to not visit.
    #
    def ignore_ports
      @port_rules.reject
    end

    #
    # Adds the given _pattern_ to the ignore_hosts. If a _block_ is given,
    # it will be added to the ignore_hosts.
    #
    def ignore_ports_like(pattern=nil,&block)
      if pattern
        ignore_ports << pattern
      elsif block
        ignore_ports << block
      end

      return self
    end

    #
    # Returns the +Array+ of link patterns to visit.
    #
    def visit_links
      @link_rules.accept
    end

    #
    # Adds the given _pattern_ to the visit_links. If a _block_ is given,
    # it will be added to the visit_links.
    #
    def visit_links_like(pattern=nil,&block)
      if pattern
        visit_links << pattern
      elsif block
        visit_links << block
      end

      return self
    end

    #
    # Returns the +Array+ of link patterns to not visit.
    #
    def ignore_links
      @link_rules.reject
    end

    #
    # Adds the given _pattern_ to the ignore_links. If a _block_ is given,
    # it will be added to the ignore_links.
    #
    def ignore_links_like(pattern=nil,&block)
      if pattern
        ignore_links << pattern
      elsif block
        ignore_links << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL extension patterns to visit.
    #
    def visit_exts
      @ext_rules.accept
    end

    #
    # Adds the given _pattern_ to the visit_exts. If a _block_ is given,
    # it will be added to the visit_exts.
    #
    def visit_exts_like(pattern=nil,&block)
      if pattern
        visit_exts << pattern
      elsif block
        visit_exts << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL extension patterns to not visit.
    #
    def ignore_exts
      @ext_rules.reject
    end

    #
    # Adds the given _pattern_ to the ignore_exts. If a _block_ is given,
    # it will be added to the ignore_exts.
    #
    def ignore_exts_like(&block)
      if pattern
        ignore_exts << pattern
      elsif block
        ignore_exts << block
      end

      return self
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
    # For every URL that the agent visits and matches the specified
    # _pattern_, it will be passed to the specified _block_.
    #
    def urls_like(pattern,&block)
      @urls_like_blocks[pattern] << block
      return self
    end

    #
    # For every Page that the agent visits it will be passed to the
    # specified _block_.
    #
    def every_page(&block)
      @every_page_blocks << block
      return self
    end

    #
    # Clear the history and start spidering at the specified _url_.
    #
    def start_at(url)
      @history.clear
      return run(url)
    end

    #
    # Start spidering at the specified _url_.
    #
    def run(url)
      enqueue(url)

      until @queue.empty?
        visit_page(dequeue)
      end

      return self
    end

    alias visited_urls history

    #
    # Returns the +Array+ of visited URLs.
    #
    def visited_links
      @history.map { |uri| uri.to_s }
    end

    #
    # Return the +Array+ of hosts that were visited.
    #
    def visited_hosts
      @history.map { |uri| uri.host }.uniq
    end

    #
    # Returns +true+ if the specified _url_ was visited, returns +false+
    # otherwise.
    #
    def visited?(url)
      if url.kind_of?(URI)
        return @history.include?(url)
      else
        return @history.include?(URI(url).to_s)
      end
    end

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

      proxy_host = @proxy[:host]
      proxy_port = @proxy[:port]
      proxy_user = @proxy[:user]
      proxy_password = @proxy[:password]

      Net::HTTP::Proxy(proxy_host,proxy_port,proxy_user,proxy_password).start(host,port) do |sess|
        headers = {}

        headers['User-Agent'] = @user_agent if @user_agent
        headers['Referer'] = @referer if @referer

        begin
          response = sess.get(path,headers)
        rescue => e
          @failed << url
        end

        new_page = Page.new(url,response)

        block.call(new_page) if block
        return new_page
      end
    end

    protected

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
        @every_url_blocks.each { |block| block.call(url) }

        @urls_like_blocks.each do |pattern,blocks|
          if ((pattern.kind_of?(Regexp) && link =~ pattern) || pattern == link || pattern == url)
            blocks.each { |url_block| url_block.call(url) }
          end
        end

        @queue << url
        return true
      end

      return false
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
       visit_scheme?(url) &&
       visit_host?(url) &&
       visit_port?(url) &&
       visit_link?(url) &&
       visit_ext?(url))
    end

    #
    # Visits the spedified _url_ and enqueus it's links for visiting. If a
    # _block_ is given, it will be passed a newly created Page object
    # for the specified _url_.
    #
    def visit_page(url,&block)
      get_page(url) do |page|
        @history << page.url

        page.urls.each { |next_url| enqueue(next_url) }

        @every_page_blocks.each { |page_block| page_block.call(page) }

        block.call(page) if block
      end
    end

    def visit_scheme?(url)
      if url.scheme
        return SCHEMES.include?(url.scheme)
      else
        return true
      end
    end

    def visit_host?(url)
      @host_rules.accept?(url.host)
    end

    def visit_port?(url)
      @port_rules.accept?(url.port)
    end

    def visit_link?(url)
      @link_rules.accept?(url.to_s)
    end

    def visit_ext?(url)
      @ext_rules.accept?(File.extname(url.path)[1..-1])
    end

  end
end
