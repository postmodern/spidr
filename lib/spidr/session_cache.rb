require 'spidr/spidr'

require 'net/http'

module Spidr
  #
  # Stores active HTTP Sessions organized by scheme, host-name and port.
  #
  class SessionCache

    # Proxy to use
    attr_accessor :proxy

    #
    # Creates a new session cache.
    #
    # @param [Hash] proxy (Spidr.proxy)
    #   Proxy options.
    #
    # @option proxy [String] :host
    #   The host the proxy is running on.
    #
    # @option proxy [Integer] :port
    #   The port the proxy is running on.
    #
    # @option proxy [String] :user
    #   The user to authenticate as with the proxy.
    #
    # @option proxy [String] :password
    #   The password to authenticate with.
    #
    # @since 0.2.2
    #
    def initialize(proxy=Spidr.proxy)
      @proxy    = proxy
      @sessions = {}
    end

    #
    # Determines if there is an active HTTP session for a given URL.
    #
    # @param [URI::HTTP, String] url
    #   The URL that represents a session.
    #
    # @return [Boolean]
    #   Specifies whether there is an active HTTP session.
    #
    # @since 0.2.3
    #
    def active?(url)
      # normalize the url
      url = URI(url.to_s) unless url.kind_of?(URI)

      # session key
      key = [url.scheme, url.host, url.port]

      return @sessions.has_key?(key)
    end

    #
    # Provides an active HTTP session for a given URL.
    #
    # @param [URI::HTTP, String] url
    #   The URL which will be requested later.
    #
    # @return [Net::HTTP]
    #   The active HTTP session object.
    #
    def [](url)
      # normalize the url
      url = URI(url.to_s) unless url.kind_of?(URI)

      # session key
      key = [url.scheme, url.host, url.port]

      unless @sessions[key]
        session = Net::HTTP::Proxy(
          @proxy[:host],
          @proxy[:port],
          @proxy[:user],
          @proxy[:password]
        ).new(url.host,url.port)

        if url.scheme == 'https'
          session.use_ssl     = true
          session.verify_mode = OpenSSL::SSL::VERIFY_NONE
          session.start
        end

        @sessions[key] = session
      end

      return @sessions[key]
    end

    #
    # Destroys an HTTP session for the given scheme, host and port.
    #
    # @param [URI::HTTP, String] url
    #   The URL of the requested session.
    #
    # @return [nil]
    #
    # @since 0.2.2
    #
    def kill!(url)
      # normalize the url
      url = URI(url.to_s) unless url.kind_of?(URI)

      # session key
      key = [url.scheme, url.host, url.port]

      if (sess = @sessions[key])
        begin 
          sess.finish
        rescue IOError
        end

        @sessions.delete(key)
      end
    end

    #
    # Clears the session cache.
    #
    # @return [SessionCache]
    #   The cleared session cache.
    #
    # @since 0.2.2
    #
    def clear
      @sessions.each_value do |sess|
        begin
          sess.finish
        rescue IOError
          nil
        end
      end

      @sessions.clear
      return self
    end

  end
end
