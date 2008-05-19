module Spidr
  class Rules

    # Accept rules
    attr_reader :accept

    # Reject rules
    attr_reader :reject

    def initialize(options={})
      @accept = (options[:accept] || [])
      @reject = (options[:reject] || [])
    end

    #
    # Returns +true+ if the _field_ is accepted by the rules,
    # returns +false+ otherwise.
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
    # Returns +true+ if the _field_ is rejected by the rules,
    # returns +false+ otherwise.
    #
    def reject?(field)
      !(accept?(field))
    end

    protected

    #
    # Tests the specified _field_ against the specified _rule_. Returns
    # +true+ when the _rule_ matches the specified _field_, returns
    # +false+ otherwise.
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
