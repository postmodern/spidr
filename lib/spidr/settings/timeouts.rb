module Spidr
  #
  # @since 0.6.0
  #
  module Timeouts
    # Read timeout.
    #
    # @return [Integer, nil]
    attr_accessor :read_timeout

    # Open timeout.
    #
    # @return [Integer, nil]
    attr_accessor :open_timeout

    # SSL timeout.
    #
    # @return [Integer, nil]
    attr_accessor :ssl_timeout

    # `Continue` timeout.
    #
    # @return [Integer, nil]
    attr_accessor :continue_timeout

    # `Keep-Alive` timeout.
    #
    # @return [Integer, nil]
    attr_accessor :keep_alive_timeout
  end
end
