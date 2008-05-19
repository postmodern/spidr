require 'spidr/rules'
require 'spidr/page'
require 'spidr/spidr'

require 'net/http'
require 'hpricot'

module Spidr
  class Agent

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

    def initialize(options={},&block)
      @proxy = (options[:proxy] || Spidr.proxy)
      @user_agent = (options[:user_agent] || Spidr.user_agent)
      @referer = options[:referer]

      @host_rules = Rules.new(:accept => options[:hosts],
                              :reject => options[:ignore_hosts])
      @port_rules = Rules.new(:accept => options[:ports],
                              :reject => options[:ignore_ports])
      @link_rules = Rules.new(:accept => options[:links],
                              :reject => options[:ignore_links])
      @ext_rules = Rules.new(:accept => options[:exts],
                             :reject => options[:ignore_exts])

      @every_url_blocks = []
      @urls_like_blocks = Hash.new { |hash,key| hash[key] = [] }

      @every_page_blocks = []

      @delay = (options[:delay] || 0)
      @history = []
      @queue = []

      block.call(self) if block
    end

    def self.start_at(page,options={},&block)
      self.new(options) do |spider|
        block.call(spider) if block

        spider.start_at(page)
      end
    end

    def self.host(name,options={},&block)
      self.new(options.merge(:hosts => [name.to_s])) do |spider|
        block.call(spider) if block

        spider.start_at("http://#{name}/")
      end
    end

    def self.site(url,options={},&block)
      url = URI(url.to_s)

      return self.new(options.merge(:hosts => [url.host])) do |spider|
        block.call(spider) if block

        spider.start_at(url)
      end
    end

    def follow_hosts
      @host_rules.accept
    end

    def follow_hosts_like(&block)
      follow_hosts << block
      return self
    end

    def ignore_hosts
      @host_rules.reject
    end

    def ignore_hosts_like(&block)
      ignore_hosts << block
      return self
    end

    def follow_ports
      @port_rules.accept
    end

    def follow_ports_like(&block)
      follow_ports << block
      return self
    end

    def ignore_ports
      @port_rules.reject
    end

    def ignore_ports_like(&block)
      ignore_ports << block
      return self
    end

    def follow_links
      @link_rules.accept
    end

    def follow_links_like(&block)
      follow_links << block
      return self
    end

    def ignore_links
      @link_rules.reject
    end

    def ignore_links_like(&block)
      ignore_links << block
      return self
    end

    def follow_exts
      @ext_rules.accept
    end

    def follow_exts_like(&block)
      follow_exts << block
      return self
    end

    def ignore_exts
      @ext_rules.reject
    end

    def ignore_exts_like(&block)
      ignore_exts << block
      return self
    end

    def every_url(&block)
      @every_url_blocks << block
      return self
    end

    def urls_like(pattern,&block)
      @urls_like_blocks[pattern] << block
      return self
    end

    def every_page(&block)
      @every_page_blocks << block
      return self
    end

    def start_at(url)
      @history.clear
      return run(url)
    end

    def run(url)
      enqueue(url)

      until @queue.empty?
        visit_page(dequeue)
      end

      return self
    end

    def visited_urls
      @history
    end

    def visited_links
      @history.map { |uri| uri.to_s }
    end

    def visited_hosts
      @history.map { |uri| uri.host }.uniq
    end

    def visited?(url)
      if url.kind_of?(URI)
        return @history.include?(url)
      else
        return @history.include?(URI(url).to_s)
      end
    end

    protected

    def queued?(url)
      @queue.include?(url)
    end

    def enqueue(url)
      link = url.to_s
      url = URI(link)

      if (!(queued?(url)) && follow?(url))
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

    def dequeue
      @queue.shift
    end

    def follow?(url)
      (!(visited?(url)) &&
       follow_scheme?(url) &&
       follow_host?(url) &&
       follow_port?(url) &&
       follow_link?(url) &&
       follow_ext?(url))
    end

    def follow_scheme?(url)
      if url.scheme
        return SCHEMES.include?(url.scheme)
      else
        return true
      end
    end

    def follow_host?(url)
      @host_rules.accept?(url.host)
    end

    def follow_port?(url)
      @port_rules.accept?(url.port)
    end

    def follow_link?(url)
      @link_rules.accept?(url.to_s)
    end

    def follow_ext?(url)
      @ext_rules.accept?(File.extname(url.path)[1..-1])
    end

    def visit_page(url,&block)
      get_page(url) do |page|
        @history << page.url

        page.urls.each { |next_url| enqueue(next_url) }

        @every_page_blocks.each { |page_block| page_block.call(page) }

        block.call(page) if block
      end
    end

    private

    def get_page(url,&block)
      host = url.host
      port = url.port

      proxy_host = @proxy[:host]
      proxy_port = @proxy[:port]
      proxy_user = @proxy[:user]
      proxy_password = @proxy[:password]

      Net::HTTP::Proxy(proxy_host,proxy_port,proxy_user,proxy_password).start(host,port) do |sess|
        headers = {}

        headers['User-Agent'] = @user_agent if @user_agent
        headers['Referer'] = @referer if @referer

        new_page = Page.new(url,sess.get(url.path,headers))

        block.call(new_page) if block
        return new_page
      end
    end

  end
end
