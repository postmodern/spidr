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
      @page.should be_ok
    end

    it "should have a content-type" do
      @page.content_type.should include('text/html')
    end

    it "should be a html page" do
      @page.should be_html
    end

    it "should have provide a document" do
      @page.doc.class.should == Nokogiri::HTML::Document
    end

    it "should allow searching the document" do
      @page.doc.search('//p').length.should == 2
      @page.doc.at('//p[2]').inner_text.should == 'Ready! Set! Go!'
    end

    it "should have a title" do
      @page.title.should == 'Spidr :: Web-Spider Obstacle Course :: Start'
    end

    it "should have links" do
      @page.links.should_not be_empty
    end
  end

  describe "txt" do
    before(:all) do
      @page = get_page('https://www.ruby-lang.org/en/LICENSE.txt')
    end

    it_should_behave_like "Page"

    it "should be OK" do
      @page.should be_ok
    end

    it "should have a content-type" do
      @page.content_type.should include('text/plain')
    end

    it "should be a txt page" do
      @page.should be_txt
    end

    it "should not have provide a document" do
      @page.doc.should be_nil
    end

    it "should not allow searching the document" do
      @page.search('//p').should be_empty
      @page.at('//p').should be_nil
    end

    it "should not have links" do
      @page.links.should be_empty
    end

    it "should not have a title" do
      @page.title.should be_nil
    end
  end

  describe "redirects" do
    before(:all) do
      @page = get_page('http://spidr.rubyforge.org/course/start.html')
      @page.stub!(:body).and_return('<meta HTTP-EQUIV="REFRESH" content="0; url=http://spidr.rubyforge.org/redirected">')
    end

    it "should provide access to page-level redirects" do
      @page.redirects_to.should == ['http://spidr.rubyforge.org/redirected']
    end 

    it "should include meta refresh redirects in the list of links" do
      @page.links.should include('http://spidr.rubyforge.org/redirected')
    end
  end

  describe "cookies" do
    before(:all) do
      @page = get_page('http://twitter.com/login')
    end

    it "should provide access to the raw Cookie" do
      cookie = @page.cookie

      cookie.should_not be_nil
      cookie.should_not be_empty
    end

    it "should provide access to the Cookies" do
      cookies = @page.cookies
      
      cookies.should_not be_empty
    end

    it "should provide access to the key->value pairs within the Cookie" do
      params = @page.cookie_params
      
      params.should_not be_empty

      params.each do |key,value|
        key.should_not be_empty
      end
    end
  end
end
