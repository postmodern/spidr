# frozen_string_literal: true

begin
  require 'robots'
rescue LoadError
end

module Spidr
  class Agent
    #
    # Initializes the robots filter.
    #
    def initialize_robots
      unless Object.const_defined?(:Robots)
        raise(ArgumentError,":robots option given but unable to require 'robots' gem")
      end

      @robots = Robots.new(@user_agent)
    end

    #
    # Determines whether a URL is allowed by the robot policy.
    #
    # @param [URI::HTTP, String] url
    #   The URL to check.
    #
    # @return [Boolean]
    #   Specifies whether a URL is allowed by the robot policy.
    #
    def robot_allowed?(url)
      if @robots
        @robots.allowed?(url)
      else
        true
      end
    end
  end
end
