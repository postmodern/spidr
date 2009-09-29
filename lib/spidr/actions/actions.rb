require 'spidr/actions/exceptions/paused'
require 'spidr/actions/exceptions/skip_link'
require 'spidr/actions/exceptions/skip_page'

module Spidr
  module Actions
    def initialize(options={},&block)
      @paused = false

      super(options,&block)
    end

    #
    # Continue spidering. If a _block_ is given, it will be passed every
    # page visited.
    #
    def continue!(&block)
      @paused = false
      return run(&block)
    end

    #
    # Sets the pause state of the agent.
    #
    def pause=(state)
      @paused = state
    end

    #
    # Pauses the agent, causing spidering to temporarily stop.
    #
    def pause!
      @paused = true
      raise(Paused)
    end

    #
    # Returns +true+ if the agent is paused, returns +false+ otherwise.
    #
    def paused?
      @paused == true
    end

    #
    # Causes the agent to skip the link being enqueued.
    #
    def skip_link!
      raise(SkipLink)
    end

    #
    # Causes the agent to skip the page being visited.
    #
    def skip_page!
      raise(SkipPage)
    end
  end
end
