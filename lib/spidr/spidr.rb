require 'spidr/agent'

module Spidr
  # Common proxy port.
  COMMON_PROXY_PORT = 8080

  #
  # Returns the +Hash+ of the Spidr proxy information.
  #
  def Spidr.proxy
    @@spidr_proxy ||= {:host => nil, :port => COMMON_PROXY_PORT, :user => nil, :password => nil}
  end

  #
  # Returns the Spidr User-Agent
  #
  def Spidr.user_agent
    @@spidr_user_agent ||= nil
  end

  #
  # Sets the Spidr Web User-Agent to the specified _new_agent_.
  #
  def Spidr.user_agent=(new_agent)
    @@spidr_user_agent = new_agent
  end

  #
  # See Agent.start_at.
  #
  def Spidr.start_at(url,options={},&block)
    Agent.start_at(url,options,&block)
  end

  #
  # See Agent.host.
  #
  def Spidr.host(name,options={},&block)
    Agent.host(name,options,&block)
  end

  #
  # See Agent.site.
  #
  def Spidr.site(url,options={},&block)
    Agent.site(url,options,&block)
  end
end
