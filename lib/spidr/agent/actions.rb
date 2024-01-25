# frozen_string_literal: true

module Spidr
  class Agent
    module Actions
      #
      # The base {Actions} exception class.
      #
      class Action < RuntimeError
      end

      #
      # An {Actions} exception class used to pause a running {Agent}.
      #
      class Paused < Action
      end

      #
      # An {Actions} exception class which causes a running {Agent} to
      # skip a link.
      #
      class SkipLink < Action
      end

      #
      # An {Actions} exception class which causes a running {Agent} to
      # skip a {Page}, and all links within that page.
      #
      class SkipPage < Action
      end
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
      raise(Actions::Paused)
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
      raise(Actions::SkipLink)
    end

    #
    # Causes the agent to skip the page being visited.
    #
    # @raise [SkipPage]
    #   Indicates to the agent, that the current page should be skipped.
    #
    def skip_page!
      raise(Actions::SkipPage)
    end

    protected

    def initialize_actions
      @paused = false
    end
  end
end
