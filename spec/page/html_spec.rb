require 'spec_helper'
require 'example_page'

require 'spidr/page'

describe Page do
  include_context "example Page"

  let(:body) { %{<html><head><title>example</title></head><body><p>hello</p></body></html>} }

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
