module Spidr
  #
  # @since 0.6.0
  #
  class Proxy < Struct.new(:host, :port, :user, :password)

    # Default port to use.
    DEFAULT_PORT = 8080

    #
    # Initializes the proxy.
    #
    # @param [String] host
    #   The host the proxy is running on.
    #
    # @param [Integer] port
    #   The port the proxy is running on.
    #
    # @param [String] user
    #   The user to authenticate as with the proxy.
    #
    # @param [String] password
    #   The password to authenticate with.
    #
    def initialize(host: nil, port: DEFAULT_PORT, user: nil, password: nil)
      super(host,port,user,password)
    end

    #
    # Determines if the proxy settings are set.
    #
    # @return [Boolean]
    #
    def enabled?
      !host.nil?
    end

    #
    # Determines if the proxy is not set.
    #
    # @return [Boolean]
    #
    def disabled?
      host.nil?
    end

  end
end
