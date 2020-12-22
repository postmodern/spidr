require 'rspec'
require 'net/http'
require 'uri'

RSpec.shared_context "example Page" do
  let(:code)          { 200 }
  let(:msg)           { 'OK'  }
  let(:content_type)  { 'text/html' }
  let(:headers)       { {} }
  let(:body)          { '' }

  let(:response) do
    Net::HTTPResponse.new('1.1', code.to_s, msg).tap do |response|
      response.set_content_type(content_type) if content_type

      headers.each do |name,values|
        if values
          Array(values).each do |value|
            response.add_field(name,value)
          end
        else
          response.remove_field(name)
        end
      end

      # stub #body, otherwise Net::HTTP will check @socket
      allow(response).to receive(:body).and_return(body)
    end
  end

  let(:host) { 'example.com' }
  let(:url)  { URI::HTTP.build(host: host) }

  subject { described_class.new(url,response) }
end
