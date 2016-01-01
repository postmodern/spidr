require 'spidr/agent'

require 'spec_helper'

describe Agent do
  describe "filters" do
    it "should allow setting the acceptable schemes" do
      agent = Agent.new

      agent.schemes = [:http]
      expect(agent.schemes).to eq(['http'])
    end

    it "should provide the hosts that will be visited" do
      agent = Agent.new(hosts: ['spidr.rubyforge.org'])

      expect(agent.visit_hosts).to eq(['spidr.rubyforge.org'])
    end

    it "should provide the hosts that will not be visited" do
      agent = Agent.new(ignore_hosts: ['example.com'])

      expect(agent.ignore_hosts).to eq(['example.com'])
    end

    it "should provide the ports that will be visited" do
      agent = Agent.new(ports: [80, 443, 8000])

      expect(agent.visit_ports).to eq([80, 443, 8000])
    end

    it "should provide the ports that will not be visited" do
      agent = Agent.new(ignore_ports: [8000, 8080])

      expect(agent.ignore_ports).to eq([8000, 8080])
    end

    it "should provide the links that will be visited" do
      agent = Agent.new(links: ['index.php'])

      expect(agent.visit_links).to eq(['index.php'])
    end

    it "should provide the links that will not be visited" do
      agent = Agent.new(ignore_links: [/login/])

      expect(agent.ignore_links).to eq([/login/])
    end

    it "should provide the exts that will be visited" do
      agent = Agent.new(exts: ['htm'])

      expect(agent.visit_exts).to eq(['htm'])
    end

    it "should provide the exts that will not be visited" do
      agent = Agent.new(ignore_exts: ['cfm'])

      expect(agent.ignore_exts).to eq(['cfm'])
    end
  end
end
