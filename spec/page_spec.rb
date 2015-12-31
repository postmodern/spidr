require 'spidr/page'

require 'spec_helper'
require 'page_examples'
require 'helpers/page'

describe Page do
  describe "html" do
    before(:all) do
      @page = get_page('http://spidr.rubyforge.org/course/start.html')
    end

    it_should_behave_like "Page"

    it "should be OK" do
      expect(@page).to be_ok
    end

    it "should have a content-type" do
      expect(@page.content_type).to include('text/html')
    end

    it "should be a html page" do
      expect(@page).to be_html
    end

    it "should have provide a document" do
      expect(@page.doc.class).to eq(Nokogiri::HTML::Document)
    end

    it "should allow searching the document" do
      expect(@page.doc.search('//p').length).to eq(2)
      expect(@page.doc.at('//p[2]').inner_text).to eq('Ready! Set! Go!')
    end

    it "should have a title" do
      expect(@page.title).to eq('Spidr :: Web-Spider Obstacle Course :: Start')
    end

    it "should have links" do
      expect(@page.links).not_to be_empty
    end
  end

  describe "txt" do
    before(:all) do
      @page = get_page('https://www.ruby-lang.org/en/about/license.txt')
    end

    it_should_behave_like "Page"

    it "should be OK" do
      expect(@page).to be_ok
    end

    it "should have a content-type" do
      expect(@page.content_type).to include('text/plain')
    end

    it "should be a txt page" do
      expect(@page).to be_txt
    end

    it "should not have provide a document" do
      expect(@page.doc).to be_nil
    end

    it "should not allow searching the document" do
      expect(@page.search('//p')).to be_empty
      expect(@page.at('//p')).to be_nil
    end

    it "should not have links" do
      expect(@page.links).to be_empty
    end

    it "should not have a title" do
      expect(@page.title).to be_nil
    end
  end

  describe "redirects" do
    before(:all) do
      @page = get_page('http://spidr.rubyforge.org/course/start.html')
    end

    before do
      allow(@page).to receive(:body).and_return('<meta HTTP-EQUIV="REFRESH" content="0; url=http://spidr.rubyforge.org/redirected">')
    end

    it "should provide access to page-level redirects" do
      expect(@page.redirects_to).to eq(['http://spidr.rubyforge.org/redirected'])
    end 

    it "should include meta refresh redirects in the list of links" do
      expect(@page.links).to include('http://spidr.rubyforge.org/redirected')
    end
  end

  describe "cookies" do
    before(:all) do
      @page = get_page('http://twitter.com/login')
    end

    it "should provide access to the raw Cookie" do
      cookie = @page.cookie

      expect(cookie).not_to be_nil
      expect(cookie).not_to be_empty
    end

    it "should provide access to the Cookies" do
      cookies = @page.cookies
      
      expect(cookies).not_to be_empty
    end

    it "should provide access to the key->value pairs within the Cookie" do
      params = @page.cookie_params
      
      expect(params).not_to be_empty

      params.each do |key,value|
        expect(key).not_to be_empty
      end
    end
  end
end
