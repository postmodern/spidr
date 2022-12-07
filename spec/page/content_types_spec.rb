require 'spec_helper'
require 'example_page'

require 'spidr/page'

describe Page do
  include_context "example Page"

  describe "#content_type" do
    it "should return the Content-Type as a String" do
      expect(subject.content_type).to be == content_type
    end

    context "when content_type is missing" do
      let(:content_type) { nil }

      it "should return an empty String" do
        expect(subject.content_type).to be == ''
      end
    end
  end

  describe "#content_types" do
    it "should return the Content-Type as an Array" do
      expect(subject.content_types).to be == [content_type]
    end

    context "when content_type is missing" do
      let(:content_type) { nil }

      it "should return an empty Array" do
        expect(subject.content_types).to be == []
      end
    end
  end

  describe "#content_charset" do
    let(:charset)      { 'utf8' }
    let(:content_type) { "text/html;charset=#{charset}" }

    it "should extract the 'charset=' param" do
      expect(subject.content_charset).to be == charset
    end

    context "when there is no 'charset='" do
      let(:content_type) { 'text/html' }

      it { expect(subject.content_charset).to be nil }
    end
  end

  describe "#is_content_type?" do
    let(:charset)      { 'utf8' }
    let(:sub_type)     { 'html' }
    let(:mime_type)    { "text/#{sub_type}" }
    let(:content_type) { "#{mime_type};charset=#{charset}" }

    context "when given a full mime-type" do
      context "and it matches the Content-Type's mime-type" do
        it { expect(subject.is_content_type?(mime_type)).to be true }
      end

      context "but it doesn't match the Content-Type's mime-type" do
        it { expect(subject.is_content_type?('text/plain')).to be false }
      end
    end

    context "when given a sub-type" do
      context "and it matches the Content-Type's sub-type" do
        it { expect(subject.is_content_type?(sub_type)).to be true }
      end

      context "but it doesn't match the Content-Type's sub-type" do
        it { expect(subject.is_content_type?('plain')).to be false }
      end
    end
  end

  shared_examples "Content-Type method" do |method,*content_types|
    content_types.each do |content_type|
      context "when Content-Type includes #{content_type}" do
        let(:content_type) { content_type }

        it { expect(subject.send(method)).to be true }
      end
    end

    context "when Content-Type does not include #{content_types.join(', ')}" do
      let(:content_type) { 'unknown/unknown' }

      it { expect(subject.send(method)).to be false }
    end
  end

  describe "#plain_text?" do
    include_examples "Content-Type method", :plain_text?, 'text/plain'
  end

  describe "#directory?" do
    include_examples "Content-Type method", :directory?, 'text/directory'
  end

  describe "#directory?" do
    include_examples "Content-Type method", :html?, 'text/html'
  end

  describe "#html?" do
    include_examples "Content-Type method", :html?, 'text/html'
  end

  describe "#xml?" do
    include_examples "Content-Type method", :xml?, 'text/xml', 'application/xml'
  end

  describe "#xsl?" do
    include_examples "Content-Type method", :xsl?, 'text/xsl'
  end

  describe "#javascript?" do
    include_examples "Content-Type method", :javascript?, 'text/javascript', 'application/javascript'
  end

  describe "#json?" do
    include_examples "Content-Type method", :json?, 'application/json'
  end

  describe "#css?" do
    include_examples "Content-Type method", :css?, 'text/css'
  end

  describe "#rss?" do
    include_examples "Content-Type method", :rss?, 'application/rss+xml', 'application/rdf+xml'
  end

  describe "#atom?" do
    include_examples "Content-Type method", :atom?, 'application/atom+xml'
  end

  describe "#ms_word?" do
    include_examples "Content-Type method", :ms_word?, 'application/msword'
  end

  describe "#pdf?" do
    include_examples "Content-Type method", :pdf?, 'application/pdf'
  end

  describe "#zip?" do
    include_examples "Content-Type method", :zip?, 'application/zip'
  end

  describe "#png?" do
    include_examples "Content-Type method", :png?, 'image/png'
  end

  describe "#gif?" do
    include_examples "Content-Type method", :gif?, 'image/gif'
  end

  describe "#jpeg?" do
    include_examples "Content-Type method", :jpeg?, 'image/jpeg'
  end
end
