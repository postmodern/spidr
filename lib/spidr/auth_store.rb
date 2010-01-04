require 'spidr/extensions/uri'
require 'spidr/auth_credential'
require 'spidr/page'

require 'base64'

module Spidr
  class AuthStore

    #
    # Creates a new Cookie Jar object.
    #
    # @since 0.2.2
    #
    def initialize
      @credentials = {}
    end

    # 
    # Given a URL, return the most specific matching auth credential.
    #
    # @param [URI] url
    #   A fully qualified url includig optional path.
    #
    # @return [AuthCredential, nil]
    #   Closest matching +AuthCredential+ values for the URL,
    #   or +nil+ if nothing matches.
    #
    # @since 0.2.2
    #
    def [](url)
      paths = @credentials[url.host]

      return nil unless paths

      # longest path first
      ordered_paths = paths.keys.sort_by { |key| key.length }.reverse

      ordered_paths.each do |path|
        return paths[path] if url.to_s.match(path.to_s)
      end

      return nil
    end

    # 
    # Add an auth credential to the store for supplied base URL.
    #
    # @param [URI] url_base
    #   A URL pattern to associate with a set of auth credentials.
    #
    # @param [AuthCredential]
    #   The auth credential for this URL pattern.
    #
    # @since 0.2.2
    #
    def []=(url, auth)
      absolute_path = URI.expand_path("#{url.path}/")

      @credentials[url.host] ||= {}
      @credentials[url.host][absolute_path] = auth
      return auth
    end

    #
    # Convenience method to add username and password credentials
    # for a named URL.
    #
    # @param [URI] url
    #   The base URL that requires authorization.
    #
    # @param [String] username
    #   The username required to access the URL.
    #
    # @param [String] password
    #   The password required to access the URL.
    #
    # @since 0.2.2
    #
    def add(url, username, password)
      self[url] = AuthCredential.new(username, password)
    end

    #
    # Returns the Base64-encoded authorization string for the URL
    # or +nil+ if no authorization exists.
    #
    # @param [URI] url
    #   The url.
    #
    # @return [String, nil]
    #   The Base64-encoded authorizatio string or +nil+.
    #
    # @since 0.2.2
    #
    def for_url(url)
      if auth = self[url]
        return Base64.encode64("#{auth.username}:#{auth.password}")
      end
    end

    # 
    # Clear out the jar, removing all stored cookies.
    #
    # @since 0.2.2
    #
    def clear!
      @credentials.clear
      return self
    end

    #
    # Size of the current auth store (number of URL paths stored).
    #
    # @since 0.2.2
    #
    def size
      @credentials.inject(0) { |res, arr| res + arr[1].length }
    end

    #
    # Inspects the auth store.
    #
    # @return [String]
    #   The inspected version of the auth store.
    #
    def inspect
      "#<#{self.class}: #{@credentials.inspect}>"
    end

  end
end
