require 'spidr/extensions/uri'

require 'spec_helper'

describe URI do
  describe "expand_path" do
    it "should preserve single directory paths" do
      expect(URI.expand_path('path')).to eq('path')
    end

    it "should preserve trailing '/'" do
      expect(URI.expand_path('test/path/')).to eq('test/path/')
    end

    it "should remove multiple '/' characters" do
      expect(URI.expand_path('///test///path///')).to eq('/test/path/')
    end

    it "should remove '.' directories from the path" do
      expect(URI.expand_path('test/./path')).to eq('test/path')
    end

    it "should handle '..' directories properly" do
      expect(URI.expand_path('test/../path')).to eq('path')
    end

    it "should limit the number of '..' directories resolved" do
      expect(URI.expand_path('/test/../../../..')).to eq('/')
    end

    it "should preserve leading '/'" do
      expect(URI.expand_path('/../../../foo')).to eq('/foo')
    end

    it "should preserve absolute paths" do
      expect(URI.expand_path('/test/path')).to eq('/test/path')
    end

    it "should preserve the root path" do
      expect(URI.expand_path('/')).to eq('/')
    end

    it "should default empty paths to the root path" do
      expect(URI.expand_path('')).to eq('/')
    end

    it "should default zero-sum paths to a '/'" do
      expect(URI.expand_path('foo/..')).to eq('/')
      expect(URI.expand_path('foo/../bar/..')).to eq('/')
      expect(URI.expand_path('././././.')).to eq('/')
    end
  end
end
