require 'spidr/extensions/uri'

require 'spec_helper'

describe URI do
  describe "expand_path" do
    it "should preserve single directory paths" do
      URI.expand_path('path').should == 'path'
    end

    it "should preserve trailing '/'" do
      URI.expand_path('test/path/').should == 'test/path/'
    end

    it "should remove multiple '/' characters" do
      URI.expand_path('///test///path///').should == '/test/path/'
    end

    it "should remove '.' directories from the path" do
      URI.expand_path('test/./path').should == 'test/path'
    end

    it "should handle '..' directories properly" do
      URI.expand_path('test/../path').should == 'path'
    end

    it "should limit the number of '..' directories resolved" do
      URI.expand_path('/test/../../../..').should == '/'
    end

    it "should preserve absolute paths" do
      URI.expand_path('/test/path').should == '/test/path'
    end

    it "should preserve the root path" do
      URI.expand_path('/').should == '/'
    end
  end
end
