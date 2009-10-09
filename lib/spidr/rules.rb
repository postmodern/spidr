module Spidr
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
    #   Patterns and rules to accept data with.
    #
    # @option options [Array<String, Regexp, Proc>] :reject
    #   Patterns and rules to reject data with.
    #
    def initialize(options={})
      @accept = (options[:accept] || [])
      @reject = (options[:reject] || [])
    end

    #
    # Determines whether the field should be accepted or rejected.
    #
    # @return [Boolean]
    #   Specifies whether the given field was accepted, using the rules
    #   acceptance patterns.
    #
    def accept?(field)
      unless @accept.empty?
        @accept.each do |rule|
          return true if test_field(field,rule)
        end

        return false
      else
        @reject.each do |rule|
          return false if test_field(field,rule)
        end

        return true
      end
    end

    #
    # Determines whether the field should be rejected or accepted.
    #
    # @return [Boolean]
    #   Specifies whether the given field was rejected, using the rules
    #   rejection patterns.
    #
    def reject?(field)
      !(accept?(field))
    end

    protected

    #
    # Tests a given field_ against a given pattern.
    #
    # @return [Boolean]
    #   Specifies whether the given field matched the pattern.
    #
    def test_field(field,rule)
      if rule.kind_of?(Proc)
        return (rule.call(field) == true)
      elsif rule.kind_of?(Regexp)
        return !((field.to_s =~ rule).nil?)
      else
        return field == rule
      end
    end

  end
end
