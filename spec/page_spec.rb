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
      @page.content_type.should =~ /text\/html/
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
      @page = get_page('http://www.example.com/robots.txt')
    end

    it_should_behave_like "Page"

    it "should be OK" do
      @page.should be_ok
    end

    it "should have a content-type" do
      @page.content_type.should =~ /text\/plain/
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

  describe "normalize" do
    before(:all) do
      @page = get_page('http://spidr.rubyforge.org/course/')
    end

    describe "path" do
      it "should preserve single directory paths" do
        @page.normalize_path('path').should == 'path'
      end

      it "should preserve trailing '/'" do
        @page.normalize_path('test/path/').should == 'test/path/'
      end

      it "should remove multiple '/' characters" do
        @page.normalize_path('///test///path///').should == '/test/path/'
      end

      it "should remove '.' directories from the path" do
        @page.normalize_path('test/./path').should == 'test/path'
      end

      it "should handle '..' directories properly" do
        @page.normalize_path('test/../path').should == 'path'
      end

      it "should limit the number of '..' directories resolved" do
        @page.normalize_path('/test/../../../..').should == '/'
      end

      it "should preserve absolute paths" do
        @page.normalize_path('/test/path').should == '/test/path'
      end

      it "should preserve the root path" do
        @page.normalize_path('/').should == '/'
      end
    end

    describe "link" do
    end
  end
end
