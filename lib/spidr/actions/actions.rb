require 'spidr/actions/exceptions/paused'
require 'spidr/actions/exceptions/skip_link'
require 'spidr/actions/exceptions/skip_page'

module Spidr
  #
  # The {Actions} module adds methods to {Agent} for controling the
  # spidering of links.
  #
  module Actions
    def initialize(options={})
      @paused = false

      super(options)
    end

    #
    # Continue spidering.
    #
    # @yield [page]
    #   If a block is given, it will be passed every page visited.
    #
    # @yieldparam [Page] page
    #   The page to be visited.
    #
    def continue!(&block)
      @paused = false
      return run(&block)
    end

    #
    # Sets the pause state of the agent.
    #
    # @param [Boolean] state
    #   The new pause state of the agent.
    #
    def pause=(state)
      @paused = state
    end

    #
    # Pauses the agent, causing spidering to temporarily stop.
    #
    # @raise [Paused]
    #   Indicates to the agent, that it should pause spidering.
    #
    def pause!
      @paused = true
      raise(Paused)
    end

    #
    # Determines whether the agent is paused.
    #
    # @return [Boolean]
    #   Specifies whether the agent is paused.
    #
    def paused?
      @paused == true
    end

    #
    # Causes the agent to skip the link being enqueued.
    #
    # @raise [SkipLink]
    #   Indicates to the agent, that the current link should be skipped,
    #   and not enqueued or visited.
    #
    def skip_link!
      raise(SkipLink)
    end

    #
    # Causes the agent to skip the page being visited.
    #
    # @raise [SkipPage]
    #   Indicates to the agent, that the current page should be skipped.
    #
    def skip_page!
      raise(SkipPage)
    end
  end
end
