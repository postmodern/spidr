module Spidr
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
end
