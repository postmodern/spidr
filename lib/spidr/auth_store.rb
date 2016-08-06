require 'spidr/extensions/uri'
require 'spidr/auth_credential'
require 'spidr/page'

require 'base64'

module Spidr
  #
  # Stores {AuthCredential} objects organized by a website's scheme,
  # host-name and sub-directory.
  #
  class AuthStore

    #
    # Creates a new auth store.
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
    #   A fully qualified url including optional path.
    #
    # @return [AuthCredential, nil]
    #   Closest matching {AuthCredential} values for the URL,
    #   or `nil` if nothing matches.
    #
    # @since 0.2.2
    #
    def [](url)
      # normalize the url
      url = URI(url)

      key = [url.scheme, url.host, url.port]
      paths = @credentials[key]

      return nil unless paths

      # longest path first
      ordered_paths = paths.keys.sort_by { |key| -key.length }

      # directories of the path
      path_dirs = URI.expand_path(url.path).split('/')

      ordered_paths.each do |path|
        return paths[path] if path_dirs[0,path.length] == path
      end

      return nil
    end

    # 
    # Add an auth credential to the store for supplied base URL.
    #
    # @param [URI] url
    #   A URL pattern to associate with a set of auth credentials.
    #
    # @param [AuthCredential] auth
    #   The auth credential for this URL pattern.
    #
    # @return [AuthCredential]
    #   The newly added auth credential.
    #
    # @since 0.2.2
    #
    def []=(url,auth)
      # normalize the url
      url = URI(url)

      # normalize the URL path
      path = URI.expand_path(url.path)

      key = [url.scheme, url.host, url.port]

      @credentials[key] ||= {}
      @credentials[key][path.split('/')] = auth
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
    # @return [AuthCredential]
    #   The newly added auth credential.
    #
    # @since 0.2.2
    #
    def add(url,username,password)
      self[url] = AuthCredential.new(username,password)
    end

    #
    # Returns the base64 encoded authorization string for the URL
    # or `nil` if no authorization exists.
    #
    # @param [URI] url
    #   The url.
    #
    # @return [String, nil]
    #   The base64 encoded authorizatio string or `nil`.
    #
    # @since 0.2.2
    #
    def for_url(url)
      if (auth = self[url])
        Base64.encode64("#{auth.username}:#{auth.password}")
      end
    end

    # 
    # Clear the contents of the auth store.
    #
    # @return [AuthStore]
    #   The cleared auth store.
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
    # @return [Integer]
    #   The size of the auth store.
    #
    # @since 0.2.2
    #
    def size
      total = 0

      @credentials.each_value { |paths| total += paths.length }

      return total
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
