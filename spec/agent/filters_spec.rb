require 'spidr/agent'

require 'spec_helper'

describe Agent do
  describe "#initialize_filters" do
    describe ":schemes" do
      it "should override the default schemes" do
        agent = described_class.new(schemes: [:https])

        expect(agent.schemes).to be == ['https']
      end
    end

    describe ":hosts" do
      it "should set the hosts that will be visited" do
        agent = described_class.new(hosts: ['spidr.rubyforge.org'])

        expect(agent.visit_hosts).to be == ['spidr.rubyforge.org']
      end
    end

    describe ":ignore_hosts" do
      it "should set the hosts that will not be visited" do
        agent = described_class.new(ignore_hosts: ['example.com'])

        expect(agent.ignore_hosts).to be == ['example.com']
      end
    end

    describe ":ports" do
      it "should set the ports that will be visited" do
        agent = described_class.new(ports: [80, 443, 8000])

        expect(agent.visit_ports).to be == [80, 443, 8000]
      end
    end

    describe ":ignore_ports" do
      it "should set the ports that will not be visited" do
        agent = described_class.new(ignore_ports: [8000, 8080])

        expect(agent.ignore_ports).to be == [8000, 8080]
      end
    end

    describe ":links" do
      it "should set the links that will be visited" do
        agent = described_class.new(links: ['index.php'])

        expect(agent.visit_links).to be == ['index.php']
      end
    end

    describe ":ignore_links" do
      it "should set the links that will not be visited" do
        agent = described_class.new(ignore_links: [/login/])

        expect(agent.ignore_links).to be == [/login/]
      end
    end

    describe ":exts" do
      it "should set the exts that will be visited" do
        agent = described_class.new(exts: ['htm'])

        expect(agent.visit_exts).to be == ['htm']
      end
    end

    describe ":ignore_exts" do
      it "should set the exts that will not be visited" do
        agent = described_class.new(ignore_exts: ['cfm'])

        expect(agent.ignore_exts).to be == ['cfm']
      end
    end
  end
end
