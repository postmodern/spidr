require 'spec_helper'
require 'example_page'

require 'spidr/page'

describe Page do
  include_context "example Page"

  let(:name)    { 'foo' }
  let(:value)   { 'bar' }
  let(:path)    { '/'   }
  let(:cookie)  { "#{name}=#{value}; Path=#{path}; Domain=#{host}; Secure; HTTPOnly" }
  let(:headers) do
    {'Set-Cookie' => cookie}
  end

  describe "#cookie" do
    it "should return the Set-Cookie header as a String" do
      expect(subject.cookie).to be == cookie
    end

    context "when Set-Cookie is not set" do
      let(:headers) { {} }

      it "should return an empty String" do
        expect(subject.cookie).to be == ''
      end
    end
  end

  describe "#cookies" do
    it "should return the Set-Cookie header as an Array" do
      expect(subject.cookies).to be == [cookie]
    end

    context "when Set-Cookie is not set" do
      let(:headers) { {} }

      it "should return an empty Array" do
        expect(subject.cookies).to be == []
      end
    end
  end

  describe "#cookie_params" do
    it "should parse the cookie params into a Hash" do
      expect(subject.cookie_params).to be == {name => value}
    end

    context "when the cookie has no value" do
      let(:value) { '' }

      it "should default the value to an empty String" do
        expect(subject.cookie_params[name]).to be == ''
      end
    end
  end
end
