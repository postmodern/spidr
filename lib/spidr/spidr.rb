require 'spidr/agent'

module Spidr
  # Common proxy port.
  COMMON_PROXY_PORT = 8080

  # Default proxy information.
  DEFAULT_PROXY = {
    :host => nil,
    :port => COMMON_PROXY_PORT,
    :user => nil,
    :password => nil
  }

  #
  # Proxy information used by all Agent objects by default.
  #
  # @return [Hash]
  #   The Spidr proxy information.
  #
  def Spidr.proxy
    @@spidr_proxy ||= DEFAULT_PROXY
  end

  #
  # Sets the proxy information used by Agent objects.
  #
  # @param [Hash] new_proxy
  #   The new proxy information.
  #
  # @option new_proxy [String] :host
  #   The host-name of the proxy.
  #
  # @option new_proxy [Integer] :port (COMMON_PROXY_PORT)
  #   The port of the proxy.
  #
  # @option new_proxy [String] :user
  #   The user to authenticate with the proxy as.
  #
  # @option new_proxy [String] :password
  #   The password to authenticate with the proxy.
  #
  # @return [Hash]
  #   The new proxy information.
  #
  def Spidr.proxy=(new_proxy)
    @@spidr_proxy = new_proxy.merge(:port => COMMON_PROXY_PORT)
  end

  #
  # Disables the proxy settings used by all newly created Agent objects.
  #
  def Spidr.disable_proxy!
    @@spidr_proxy = DEFAULT_PROXY
    return true
  end

  #
  # The User-Agent string used by all Agent objects by default.
  #
  # @return [String]
  #   The Spidr User-Agent string.
  #
  def Spidr.user_agent
    @@spidr_user_agent ||= nil
  end

  #
  # Sets the Spidr User-Agent string.
  #
  # @param [String] new_agent
  #   The new User-Agent string.
  #
  def Spidr.user_agent=(new_agent)
    @@spidr_user_agent = new_agent
  end

  #
  # @see Agent.start_at
  #
  def Spidr.start_at(url,options={},&block)
    Agent.start_at(url,options,&block)
  end

  #
  # @see Agent.host
  #
  def Spidr.host(name,options={},&block)
    Agent.host(name,options,&block)
  end

  #
  # @see Agent.site
  #
  def Spidr.site(url,options={},&block)
    Agent.site(url,options,&block)
  end
end
