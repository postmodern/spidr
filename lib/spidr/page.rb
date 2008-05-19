require 'uri'
require 'hpricot'

module Spidr
  class Page

    # URL of the page
    attr_reader :url

    # Body returned for the page
    attr_reader :body

    # Headers returned with the body
    attr_reader :headers

    def initialize(url,response)
      @url = url
      @response = response
      @doc = nil
    end

    #
    # Returns the content-type of the page.
    #
    def content_type
      @response['Content-Type']
    end

    #
    # Returns +true+ if the page is a HTML document, returns +false+
    # otherwise.
    #
    def html?
      (content_type =~ /text\/html/) == 0
    end

    #
    # Returns +true+ if the page is a XML document, returns +false+
    # otherwise.
    #
    def xml?
      (content_type =~ /text\/xml/) == 0
    end

    #
    # Returns +true+ if the page is a Javascript file, returns +false+
    # otherwise.
    #
    def javascript?
      (content_type =~ /(text|application)\/javascript/) == 0
    end

    #
    # Returns +true+ if the page is a CSS file, returns +false+
    # otherwise.
    #
    def css?
      (content_type =~ /text\/css/) == 0
    end

    #
    # Returns +true+ if the page is a RSS/RDF feed, returns +false+
    # otherwise.
    #
    def rss?
      (content_type =~ /application\/(rss|rdf)\+xml/) == 0
    end

    #
    # Returns +true+ if the page is a Atom feed, returns +false+
    # otherwise.
    #
    def atom?
      (content_type =~ /application\/atom\+xml/) == 0
    end

    def body
      @response.body
    end

    #
    # Returns an Hpricot::Doc if the page represents a HTML document,
    # returns +nil+ otherwise.
    #
    def doc
      if html?
        return @doc ||= Hpricot(body)
      end
    end

    def links
      if html?
        return doc.search('a[@href]').map do |a|
          a.attributes['href'].strip
        end
      end

      return []
    end

    def urls
      links.map { |link| to_absolute(link) }
    end

    protected

    def to_absolute(link)
      link = URI.encode(link.to_s.gsub(/#.*$/,''))
      relative = URI(link)

      if relative.scheme.nil?
        new_url = @url.clone

        if relative.path[0..0] == '/'
          new_url.path = relative.path
        elsif relative.path[-1..-1] == '/'
          new_url.path = File.expand_path(File.join(new_url.path,relative.path))
        elsif !(relative.path.empty?)
          new_url.path = File.expand_path(File.join(File.dirname(new_url.path),relative.path))
        end

        return new_url
      end

      return relative
    end

    #
    # Provides transparent access to the values in the +headers+ +Hash+.
    #
    def method_missing(sym,*args,&block)
      if (args.empty? && block.nil?)
        name = sym.id2name.sub('_','-')

        return @response[name] if @response.has_key?(name)
      end

      return super(sym,*args,&block)
    end

  end
end
