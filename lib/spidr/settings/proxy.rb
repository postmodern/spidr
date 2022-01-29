require 'spidr/proxy'

module Spidr
  module Settings
    #
    # Methods for configuring a proxy.
    #
    # @since 0.6.0
    #
    module Proxy
      #
      # Proxy information used by all newly created Agent objects by default.
      #
      # @return [Spidr::Proxy]
      #   The Spidr proxy information.
      #
      def proxy
        @proxy ||= Spidr::Proxy.new
      end

      #
      # Sets the proxy information used by Agent objects.
      #
      # @param [Spidr::Proxy, Hash, nil] new_proxy
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
      # @return [Spidr::Proxy]
      #   The new proxy information.
      #
      def proxy=(new_proxy)
        @proxy = case new_proxy
                 when Spidr::Proxy then new_proxy
                 when Hash         then Spidr::Proxy.new(**new_proxy)
                 when nil          then Spidr::Proxy.new
                 else
                   raise(TypeError,"#{self.class}#{__method__} only accepts Proxy, Hash or nil")
                 end
      end

      #
      # Disables the proxy settings used by all newly created Agent objects.
      #
      def disable_proxy!
        @proxy = Spidr::Proxy.new
        return true
      end
    end
  end
end
