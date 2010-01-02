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
    def [](host)
      @cookies[host]
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
    def []=(host,cookie)
      @cookies[host] = cookie
    end

    #
    # Retrieve cookies for a domain from a page response header.
    #
    # @param [Page] page
    #   The response page from which to extract cookie data.
    #
    # @return [Boolean]
    #   Specifies whether cookies were added from the page.
    #
    # @since 0.2.2
    #
    def from_page(page)
      cookie = page.cookie_values.join('; ')

      unless cookie.empty?
        self[page.url.host] = cookie
        return true
      end

      return false
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
    # Size of the current cookie jar store.
    #
    # @since 0.2.2
    #
    def size
      @cookies.size
    end

  end
end
