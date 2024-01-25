# frozen_string_literal: true

require_relative 'settings/proxy'
require_relative 'settings/timeouts'
require_relative 'settings/user_agent'
require_relative 'agent'

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
    @robots ||= false
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
  def self.start_at(url,**kwargs,&block)
    Agent.start_at(url,**kwargs,&block)
  end

  #
  # @see Agent.host
  #
  def self.host(name,**kwargs,&block)
    Agent.host(name,**kwargs,&block)
  end

  #
  # @see Agent.domain
  #
  # @since 0.7.0
  #
  def self.domain(name,**kwargs,&block)
    Agent.domain(name,**kwargs,&block)
  end

  #
  # @see Agent.site
  #
  def self.site(url,**kwargs,&block)
    Agent.site(url,**kwargs,&block)
  end

  #
  # @abstract
  #
  def self.robots
  end
end
