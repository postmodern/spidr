require_relative 'page'

require 'set'

module Spidr
  #
  # Stores HTTP Cookies organized by host-name.
  #
  class CookieJar

    include Enumerable

    #
    # Creates a new Cookie Jar object.
    #
    # @since 0.2.2
    #
    def initialize
      @params = {}

      @dirty   = Set[]
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
      @params.each(&block)
    end

    #
    # Return all relevant cookies in a single string for the
    # named host or domain (in browser request format).
    #
    # @param [String] host
    #   Host or domain name for cookies.
    #
    # @return [String, nil]
    #   The cookie values or `nil` if the host does not have a cookie in the
    #   jar.
    #
    # @since 0.2.2
    #
    def [](host)
      @params[host] ||= {}
    end

    #
    # Add a cookie to the jar for a particular domain.
    #
    # @param [String] host
    #   Host or domain name to associate with the cookie.
    #
    # @param [Hash{String => String}] cookies
    #   Cookie params.
    #
    # @since 0.2.2
    #
    def []=(host,cookies)
      collected = self[host]

      cookies.each do |key,value|
        if collected[key] != value
          collected.merge!(cookies)
          @dirty << host

          break
        end
      end

      return cookies
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
      cookies = page.cookie_params

      unless cookies.empty?
        self[page.url.host] = cookies
        return true
      end

      return false
    end

    #
    # Returns the pre-encoded Cookie for a given host.
    #
    # @param [String] host
    #   The name of the host.
    #
    # @return [String]
    #   The encoded Cookie.
    #
    # @since 0.2.2
    #
    def for_host(host)
      if @dirty.include?(host)
        values = []

        cookies_for_host(host).each do |name,value|
          values << "#{name}=#{value}"
        end

        @cookies[host] = values.join('; ')
        @dirty.delete(host)
      end

      return @cookies[host]
    end

    #
    # Returns raw cookie value pairs for a given host. Includes cookies set on
    # parent domain(s).
    #
    # @param [String] host
    #   The name of the host.
    #
    # @return [Hash{String => String}]
    #   Cookie params.
    #
    # @since 0.2.7
    #
    def cookies_for_host(host)
      host_cookies = (@params[host] || {})
      sub_domains  = host.split('.')

      while sub_domains.length > 2
        sub_domains.shift

        if (parent_cookies = @params[sub_domains.join('.')])
          parent_cookies.each do |name,value|
            # copy in the parent cookies, only if they haven't been
            # overridden yet.
            unless host_cookies.has_key?(name)
              host_cookies[name] = value
            end
          end
        end
      end

      return host_cookies
    end

    #
    # Clear out the jar, removing all stored cookies.
    #
    # @since 0.2.2
    #
    def clear!
      @params.clear

      @dirty.clear
      @cookies.clear
      return self
    end

    #
    # Size of the current cookie jar store.
    #
    # @since 0.2.2
    #
    def size
      @params.size
    end

    #
    # Inspects the cookie jar.
    #
    # @return [String]
    #   The inspected version of the cookie jar.
    #
    def inspect
      "#<#{self.class}: #{@params.inspect}>"
    end

  end
end
