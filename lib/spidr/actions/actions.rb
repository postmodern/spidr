require 'spidr/actions/exceptions/paused'

module Spidr
  module Actions
    def initialize(options={},&block)
      @paused = true

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
  end
end
