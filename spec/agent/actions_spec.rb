require 'spec_helper'
require 'example_app'

require 'spidr/agent'

describe Agent do
  describe "#continue!" do
    before { subject.pause = true }
    before { subject.continue!    }

    it "should un-pause the Agent" do
      expect(subject.paused?).to be false
    end
  end

  describe "#pause=" do
    it "should change the paused state" do
      subject.pause = true

      expect(subject.paused?).to be true
    end
  end

  describe "#pause!" do
    it "should raise Action::Paused" do
      expect {
        subject.pause!
      }.to raise_error(described_class::Actions::Paused)
    end
  end

  describe "#paused?" do
    context "when the agent is paused" do
      before do
        begin
          subject.pause!
        rescue described_class::Actions::Paused
        end
      end

      it { expect(subject.paused?).to be true }
    end

    context "when the agent is not paused" do
      it { expect(subject.paused?).to be false }
    end
  end

  describe "#skip_link!" do
    it "should raise Actions::SkipLink" do
      expect {
        subject.skip_link!
      }.to raise_error(described_class::Actions::SkipLink)
    end
  end

  describe "#skip_page!" do
    it "should raise Actions::SkipPage" do
      expect {
        subject.skip_page!
      }.to raise_error(described_class::Actions::SkipPage)
    end
  end

  context "when spidering" do
    include_context "example App"

    context "when pause! is called" do
      app do
        get '/' do
          %{<html><body><a href="/link">link</a></body></html>}
        end

        get '/link' do
          %{<html><body>should not get here</body></html>}
        end
      end

      subject do
        described_class.new(host: host) do |agent|
          agent.every_page do |page|
            if page.url.path == '/'
              agent.pause!
            end
          end
        end
      end

      it "should pause spidering" do
        expect(subject).to be_paused
        expect(subject.history).to be == Set[
          URI("http://#{host}/")
        ]
      end

      context "and continue! is called afterwards" do
        before do
          subject.enqueue "http://#{host}/link"
          subject.continue!
        end

        it "should continue spidering" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/link")
          ]
        end
      end
    end

    context "when skip_link! is called" do
      app do
        get '/' do
          %{<html><body><a href="/link1">link1</a> <a href="/link2">link2</a> <a href="/link3">link3</a></body></html>}
        end

        get '/link1' do
          %{<html><body>link1</body></html>}
        end

        get '/link2' do
          %{<html><body>link2</body></html>}
        end

        get '/link3' do
          %{<html><body>link3</body></html>}
        end
      end

      subject do
        described_class.new(host: host) do |agent|
          agent.every_url do |url|
            if url.path == '/link2'
              agent.skip_link!
            end
          end
        end
      end

      it "should skip all links on the page" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/link1"),
          URI("http://#{host}/link3")
        ]
      end
    end

    context "when skip_page! is called" do
      app do
        get '/' do
          %{<html><body><a href="/link">entry link</a></body></html>}
        end

        get '/link' do
          %{<html><body><a href="/link1">link1</a> <a href="/link2">link2</a></body></html>}
        end

        get '/link1' do
          %{<html><body>should not get here</body></html>}
        end

        get '/link2' do
          %{<html><body>should not get here</body></html>}
        end
      end

      subject do
        described_class.new(host: host) do |agent|
          agent.every_page do |page|
            if page.url.path == '/link'
              agent.skip_page!
            end
          end
        end
      end

      it "should skip all links on the page" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/link")
        ]
      end
    end
  end
end
