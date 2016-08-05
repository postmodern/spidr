require 'rspec'
require 'sinatra/base'
require 'webmock/rspec'

require 'spidr/agent'

RSpec.shared_context "example App" do
  let(:host) { 'example.com' }

  subject { Agent.new(host: host) }

  def self.app(&block)
    let(:app) do
      klass = Class.new(Sinatra::Base)
      klass.set :host, host
      klass.set :port, 80
      klass.class_eval(&block)
      return klass
    end

    before do
      stub_request(:any, /#{Regexp.escape(host)}/).to_rack(app)

      subject.start_at("http://#{host}/")
    end

    after { WebMock.reset! }
  end
end
