require 'spidr/page'

module Spidr
  class CookieJar

    #
    # Creates a new Cookie Jar object.
    #
    def initialize
      @cookies = {}
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
      page.cookies.each do |cookie|
        cookie = cookie.split(';')[0]
        # TODO: respect domain, expire values (cookie attributes)

        add(page.url.host, cookie)
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
