module Spidr
  module Settings
    #
    # @since 0.6.0
    #
    module UserAgent
      # The User-Agent string used by all Agent objects by default.
      #
      # @return [String]
      #   The Spidr User-Agent string.
      attr_accessor :user_agent
    end
  end
end
