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
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [Array<String, Regexp, Proc>] :accept
    #   The patterns to accept data with.
    #
    # @option options [Array<String, Regexp, Proc>] :reject
    #   The patterns to reject data with.
    #
    def initialize(options={})
      @accept = []
      @reject = []

      @accept += options[:accept] if options[:accept]
      @reject += options[:reject] if options[:reject]
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
        @accept.each do |rule|
          return true if test_data(data,rule)
        end

        return false
      else
        @reject.each do |rule|
          return false if test_data(data,rule)
        end

        return true
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
      !(accept?(data))
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
        return (rule.call(data) == true)
      elsif rule.kind_of?(Regexp)
        return !((data.to_s =~ rule).nil?)
      else
        return data == rule
      end
    end

  end
end
