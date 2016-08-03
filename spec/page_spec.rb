require 'spec_helper'
require 'example_page'

require 'spidr/page'

describe Page do
  include_context "example Page"

  describe "#initialize" do
    let(:headers) { {'X-Foo' => 'bar'} }

    it "should set #url" do
      expect(subject.url).to be url
    end

    it "should set #headers" do
      expect(subject.headers).to be == {
        'content-type' => [content_type],
        'x-foo'        => ['bar']
      }
    end
  end

  describe "method_missing" do
    let(:headers) { {'X-Foo' => 'bar'} }

    it "should provide transparent access to headers" do
      expect(subject.x_foo).to be == 'bar'
    end

    context "when the requested header does not exist" do
      it do
        expect { subject.x_bar }.to raise_error(NoMethodError)
      end
    end

    context "when method arguments are also given" do
      it do
        expect { subject.x_foo(1) }.to raise_error(NoMethodError)
      end
    end

    context "when a block is also given" do
      it do
        expect { subject.x_foo { } }.to raise_error(NoMethodError)
      end
    end
  end
end
