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
    #
    # @return [String, nil]
    #   The cookie values or +nil+ if the host does not have a cookie in the
    #   jar.
    #
    def cookies_for(host)
      if @cookies.has_key?(host)
        return @cookies[host].join('; ')
      end
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
      page.cookie_values.each do |cookie|
        add(page.url.host,cookie)
      end
    end

    #
    # Size of the current cookie jar store.
    #
    def size
      @cookies.size
    end

  end
end
