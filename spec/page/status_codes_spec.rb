require 'spec_helper'
require 'example_page'

require 'spidr/page'

describe Page do
  include_context "example Page"

  describe "#code" do
    it "should return the Integer version of the response status code" do
      expect(subject.code).to be code
    end
  end

  shared_examples "status code method" do |method,status_codes|
    status_codes.each do |code,expected|
      context "when status code is #{code}" do
        let(:code) { code }

        it { expect(subject.send(method)).to be expected }
      end
    end
  end

  describe "#is_ok?" do
    include_examples "status code method", :is_ok?, {200 => true, 500 => false}
  end

  describe "#bad_request?" do
    include_examples "status code method", :bad_request?, {400 => true, 200 => false}
  end

  describe "#is_unauthorized?" do
    include_examples "status code method", :is_unauthorized?, {401 => true, 200 => false}
  end

  describe "#is_forbidden?" do
    include_examples "status code method", :is_forbidden?, {403 => true, 200 => false}
  end

  describe "#is_missing?" do
    include_examples "status code method", :is_missing?, {404 => true, 200 => false}
  end

  describe "#is_timedout?" do
    include_examples "status code method", :is_timedout?, {408 => true, 200 => false}
  end

  describe "#had_internal_server_error?" do
    include_examples "status code method", :had_internal_server_error?, {500 => true, 200 => false}
  end

  describe "#is_redirect?" do
    include_examples "status code method", :is_redirect?, {
      300 => true,
      301 => true,
      302 => true,
      303 => true,
      304 => false,
      305 => false,
      306 => false,
      307 => true
    }

    context "when code is 200" do
      context "and there is a meta refresh redirect" do
        let(:body) do
          %{<html><head><meta http-equiv="refresh" content="0; url=/other" /></head><body>redirecting...</body></html>}
        end

        it { expect(subject.is_redirect?).to be true }
      end

      context "and there is no meta refresh redirect" do
        let(:body) { %{<html><body>foo</body></html>} }

        it { expect(subject.is_redirect?).to be false }
      end
    end

    context "when that status code is not 30x or 200" do
      let(:code) { 404 }

      it { expect(subject.is_redirect?).to be false }
    end
  end
end
