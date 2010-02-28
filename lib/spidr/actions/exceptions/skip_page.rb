require 'spidr/actions/exceptions/action'

module Spidr
  module Actions
    #
    # An {Actions} exception class which causes a running {Agent} to
    # skip a {Page}, and all links within that page.
    #
    class SkipPage < Action
    end
  end
end
