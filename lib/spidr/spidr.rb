require 'spidr/proxy'
require 'spidr/has_proxy'
require 'spidr/agent'

module Spidr
  extend HasProxy

  class << self
    # Read timeout.
    #
    # @return [Integer, nil]
    #
    # @since 0.6.0
    attr_accessor :read_timeout

    # Open timeout.
    #
    # @return [Integer, nil]
    #
    # @since 0.6.0
    attr_accessor :open_timeout

    # SSL timeout.
    #
    # @return [Integer, nil]
    #
    # @since 0.6.0
    attr_accessor :ssl_timeout

    # `Continue` timeout.
    #
    # @return [Integer, nil]
    #
    # @since 0.6.0
    attr_accessor :continue_timeout

    # `Keep-Alive` timeout.
    #
    # @return [Integer, nil]
    #
    # @since 0.6.0
    attr_accessor :keep_alive_timeout

    # The User-Agent string used by all Agent objects by default.
    #
    # @return [String]
    #   The Spidr User-Agent string.
    attr_accessor :user_agent
  end

  #
  # Specifies whether `robots.txt` should be honored globally.
  #
  # @return [Boolean]
  #
  # @since 0.5.0
  #
  def self.robots?
    @@robots
  end

  #
  # Enables or disables `robots.txt` globally.
  #
  # @param [Boolean] mode
  #
  # @return [Boolean]
  #
  # @since 0.5.0
  #
  def self.robots=(mode)
    @@robots = mode
  end

  #
  # @see Agent.start_at
  #
  def self.start_at(url,options={},&block)
    Agent.start_at(url,options,&block)
  end

  #
  # @see Agent.host
  #
  def self.host(name,options={},&block)
    Agent.host(name,options,&block)
  end

  #
  # @see Agent.site
  #
  def self.site(url,options={},&block)
    Agent.site(url,options,&block)
  end

  # 
  # @abstract
  #
  def self.robots
  end
end
