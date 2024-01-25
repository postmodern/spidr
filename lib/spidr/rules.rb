# frozen_string_literal: true

module Spidr
  #
  # The {Rules} class represents collections of acceptance and rejection
  # rules, which are used to filter data.
  #
  class Rules

    # Accept rules
    attr_reader :accept

    # Reject rules
    attr_reader :reject

    #
    # Creates a new Rules object.
    #
    # @param [Array<String, Regexp, Proc>, nil] accept
    #   The patterns to accept data with.
    #
    # @param [Array<String, Regexp, Proc>, nil] reject
    #   The patterns to reject data with.
    #
    def initialize(accept: nil, reject: nil)
      @accept = []
      @reject = []

      @accept += accept if accept
      @reject += reject if reject
    end

    #
    # Determines whether the data should be accepted or rejected.
    #
    # @return [Boolean]
    #   Specifies whether the given data was accepted, using the rules
    #   acceptance patterns.
    #
    def accept?(data)
      unless @accept.empty?
        @accept.any? { |rule| test_data(data,rule) }
      else
        !@reject.any? { |rule| test_data(data,rule) }
      end
    end

    #
    # Determines whether the data should be rejected or accepted.
    #
    # @return [Boolean]
    #   Specifies whether the given data was rejected, using the rules
    #   rejection patterns.
    #
    def reject?(data)
      !accept?(data)
    end

    protected

    #
    # Tests the given data against a given pattern.
    #
    # @return [Boolean]
    #   Specifies whether the given data matched the pattern.
    #
    def test_data(data,rule)
      if rule.kind_of?(Proc)
        rule.call(data) == true
      elsif rule.kind_of?(Regexp)
        !((data.to_s =~ rule).nil?)
      else
        data == rule
      end
    end

  end
end
