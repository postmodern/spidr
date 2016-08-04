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

  describe "#body" do
    context "when there is a body" do
      let(:body) { %{<html><head><title>example</title></head><body><p>hello</p></body></html>} }

      it "should return the body text" do
        expect(subject.body).to be body
      end
    end

    context "when there is no body" do
      it "should return an empty String" do
        expect(subject.body).to be == ''
      end
    end
  end

  describe "#doc" do
    context "when the Content-Type is text/html" do
      let(:body) { %{<html><head><title>example</title></head><body><p>hello</p></body></html>} }

      it "should parse the body as HTML" do
        expect(subject.doc).to be_kind_of(Nokogiri::HTML::Document)
        expect(subject.doc.at('//p').inner_text).to be == 'hello'
      end
    end

    context "when the document is application/rss+xml" do
      let(:content_type) { 'application/rss+xml' }
      let(:body) do
        %{<?xml version="1.0" encoding="UTF-8" ?><rss version="2.0"></rss>}
      end

      it "should parse the body as XML" do
        expect(subject.doc).to be_kind_of(Nokogiri::XML::Document)
      end
    end

    context "when the document is application/atom+xml" do
      let(:content_type) { 'application/atom+xml' }
      let(:body) do
        %{<?xml version="1.0" encoding="UTF-8" ?><feed xmlns="http://www.w3.org/2005/Atom"></feed>}
      end

      it "should parse the body as XML" do
        expect(subject.doc).to be_kind_of(Nokogiri::XML::Document)
      end
    end

    context "when the document is text/xml" do
      let(:content_type) { 'text/xml' }
      let(:body) do
        %{<?xml version="1.0" encoding="UTF-8" ?><foo />}
      end

      it "should parse the body as XML" do
        expect(subject.doc).to be_kind_of(Nokogiri::XML::Document)
      end
    end

    context "when the document is text/xsl" do
      let(:content_type) { 'text/xsl' }
      let(:body) do
        %{<?xml version="1.0" encoding="UTF-8" ?><xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"></xsl:stylesheet>}
      end

      it "should parse the body as XML" do
        expect(subject.doc).to be_kind_of(Nokogiri::XML::Document)
      end
    end

    context "when there is no body" do
      it "should return an empty String" do
        expect(subject.doc).to be nil
      end
    end
  end

  describe "#search" do
    context "when there is a document" do
      let(:body) { %{<html><head><title>example</title></head><body><p>hello</p></body></html>} }

      it "should search the document" do
        expect(subject.search('//p').inner_text).to be == 'hello'
      end
    end

    context "when there is no document" do
      it "should return an empty Array" do
        expect(subject.search('//p')).to be == []
      end
    end
  end

  describe "#at" do
    context "when there is a document" do
      let(:body) { %{<html><head><title>example</title></head><body><p>hello</p></body></html>} }

      it "should search the document for the first matching node" do
        expect(subject.at('//p').inner_text).to be == 'hello'
      end
    end

    context "when there is no document" do
      it "should return nil" do
        expect(subject.at('//p')).to be nil
      end
    end
  end

  describe "#to_s" do
    it "should return the body" do
      expect(subject.to_s).to be body
    end
  end
end
