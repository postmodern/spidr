require 'spidr/settings/proxy'
require 'spidr/settings/timeouts'
require 'spidr/settings/user_agent'
require 'spidr/agent'

module Spidr
  extend Settings::Proxy
  extend Settings::Timeouts
  extend Settings::UserAgent

  #
  # Specifies whether `robots.txt` should be honored globally.
  #
  # @return [Boolean]
  #
  # @since 0.5.0
  #
  def self.robots?
    @robots
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
    @robots = mode
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
