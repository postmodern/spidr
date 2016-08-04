require 'spec_helper'
require 'example_page'

require 'spidr/page'

describe Page do
  include_context "example Page"

  let(:body) { %{<html><head><title>example</title></head><body><p>hello</p></body></html>} }

  describe "#body" do
    it "should return the body text" do
      expect(subject.body).to be body
    end

    context "when there is no body" do
      before do
        allow(response).to receive(:body).and_return(nil)
      end

      it "should return an empty String" do
        expect(subject.body).to be == ''
      end
    end
  end

  describe "#doc" do
    context "when the Content-Type is text/html" do
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
      before do
        allow(response).to receive(:body).and_return(nil)
      end

      it "should return an empty String" do
        expect(subject.doc).to be nil
      end
    end
  end

  describe "#search" do
    context "when there is a document" do
      it "should search the document" do
        expect(subject.search('//p').inner_text).to be == 'hello'
      end
    end

    context "when there is no document" do
      before do
        allow(response).to receive(:body).and_return(nil)
      end

      it "should return an empty Array" do
        expect(subject.search('//p')).to be == []
      end
    end
  end

  describe "#at" do
    context "when there is a document" do
      it "should search the document for the first matching node" do
        expect(subject.at('//p').inner_text).to be == 'hello'
      end
    end

    context "when there is no document" do
      before do
        allow(response).to receive(:body).and_return(nil)
      end

      it "should return nil" do
        expect(subject.at('//p')).to be nil
      end
    end
  end

  describe "#title" do
    context "when there is a title" do
      it "should return the title inner_text" do
        expect(subject.title).to be == 'example'
      end
    end

    context "when there is no title" do
      let(:body) { %{<html><head></head><body><p>hello</p></body></html>} }

      it "should return nil" do
        expect(subject.title).to be nil
      end
    end
  end

  describe "#to_s" do
    it "should return the body" do
      expect(subject.to_s).to be body
    end
  end
end
