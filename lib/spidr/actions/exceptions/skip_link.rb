require 'spidr/actions/exceptions/action'

module Spidr
  module Actions
    #
    # An {Actions} exception class which causes a running {Agent} to
    # skip a link.
    #
    class SkipLink < Action
    end
  end
end
