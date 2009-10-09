require 'spidr/agent'

module Spidr
  # Common proxy port.
  COMMON_PROXY_PORT = 8080

  #
  # Proxy information used by all Agent objects by default.
  #
  # @return [Hash]
  #   The Spidr proxy information.
  #
  def Spidr.proxy
    @@spidr_proxy ||= {:host => nil, :port => COMMON_PROXY_PORT, :user => nil, :password => nil}
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
  # Sets the Spidr Web User-Agent string.
  #
  # @param [String] new_agent
  #   The new User-Agent string.
  #
  def Spidr.user_agent=(new_agent)
    @@spidr_user_agent = new_agent
  end

  #
  # @see Agent.start_at.
  #
  def Spidr.start_at(url,options={},&block)
    Agent.start_at(url,options,&block)
  end

  #
  # @see Agent.host.
  #
  def Spidr.host(name,options={},&block)
    Agent.host(name,options,&block)
  end

  #
  # @see Agent.site.
  #
  def Spidr.site(url,options={},&block)
    Agent.site(url,options,&block)
  end
end
