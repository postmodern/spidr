require 'spidr/page'

module Spidr
  class CookieJar

    include Enumerable

    #
    # Creates a new Cookie Jar object.
    #
    # @since 0.2.2
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
    # @since 0.2.2
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
    # @since 0.2.2
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
    # @since 0.2.2
    #
    def cookies_for(host)
      if @cookies.has_key?(host)
        return @cookies[host].join('; ')
      end
    end

    # 
    # Clear out the jar, removing all stored cookies.
    #
    # @since 0.2.2
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
    # @since 0.2.2
    #
    def from_page(page)
      page.cookie_values.each do |cookie|
        add(page.url.host,cookie)
      end
    end

    #
    # Size of the current cookie jar store.
    #
    # @since 0.2.2
    #
    def size
      @cookies.size
    end

  end
end
