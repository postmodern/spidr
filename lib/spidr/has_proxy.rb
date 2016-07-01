require 'spidr/proxy'

module Spidr
  #
  # Methods for configuring a proxy.
  #
  # @since 0.6.0
  #
  module HasProxy
    #
    # Proxy information used by all newly created Agent objects by default.
    #
    # @return [Proxy]
    #   The Spidr proxy information.
    #
    def proxy
      @proxy || Proxy.new
    end

    #
    # Sets the proxy information used by Agent objects.
    #
    # @param [Hash, nil] new_proxy
    #   The new proxy information.
    #
    # @option new_proxy [String] :host
    #   The host-name of the proxy.
    #
    # @option new_proxy [Integer] :port (COMMON_PROXY_PORT)
    #   The port of the proxy.
    #
    # @option new_proxy [String] :user
    #   The user to authenticate with the proxy as.
    #
    # @option new_proxy [String] :password
    #   The password to authenticate with the proxy.
    #
    # @return [Proxy]
    #   The new proxy information.
    #
    def proxy=(new_proxy)
      @proxy = case new_proxy
               when Proxy then new_proxy
               when Hash  then Proxy.new(new_proxy)
               when nil   then Proxy.new
               else
                 raise(TypeError,"#{self.class}#{__method__} only accepts Proxy, Hash or nil")
               end
    end

    #
    # Disables the proxy settings used by all newly created Agent objects.
    #
    def self.disable_proxy!
      @proxy = Proxy.new
      return true
    end
  end
end
