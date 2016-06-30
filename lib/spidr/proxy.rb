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
    # @param [Hash] attributes
    #   Attributes for the proxy.
    #
    # @option attributes [String] :host
    #   The host the proxy is running on.
    #
    # @option attributes [Integer] :port
    #   The port the proxy is running on.
    #
    # @option attributes [String] :user
    #   The user to authenticate as with the proxy.
    #
    # @option attributes [String] :password
    #   The password to authenticate with.
    #
    def initialize(attributes={})
      super(
        attributes[:host],
        attributes.fetch(:port,DEFAULT_PORT),
        attributes[:user],
        attributes[:password]
      )
    end

  end
end
