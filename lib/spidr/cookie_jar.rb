require 'spidr/page'

module Spidr
  class CookieJar

    include Enumerable

    #
    # Creates a new Cookie Jar object.
    #
    def initialize
      @cookies = {}
    end

    #
    # Enumerates over the host-name and cookie value pairs in the
    # cookie jar.
    #
    # @yield [host, cookie]
    #   If a block is given, it will be passed each host-name and cookie
    #   value pair.
    #
    # @yieldparam [String] host
    #   The host-name that the cookie is bound to.
    #
    # @yieldparam [String] cookie
    #   The cookie value.
    #
    def each(&block)
      @cookies.each(&block)
    end

    # 
    # Add a cookie to the jar for a particular domain.
    #
    # @param [String] host
    #   Host or domain name to associate with the cookie.
    #
    # @param [String] cookie
    #   Cookie data.
    #
    def add(host, cookie)
      @cookies[host] ||= []
      @cookies[host] << cookie
    end

    # 
    # Return all relevant cookies in a single string for the 
    # named host or domain (in browser request format).
    #
    # @param [String] host
    #   Host or domain name for cookies.
    def cookies_for(host)
      (@cookies[host] || []).join('; ')
    end

    # 
    # Clear out the jar, removing all stored cookies.
    #
    def clear!
      @cookies.clear
    end

    #
    # Retrieve cookies for a domain from a page response header.
    #
    # @param [Page] page
    #   The response page from which to extract cookie data.
    #
    def from_page(page)
      page.cookies.each { |host,cookie| add(host,cookie) }
    end

    #
    # Size of the current cookie jar store.
    #
    def size
      @cookies.size
    end

  end
end
