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

    #
    # Creates a new Page object from the specified _url_ and HTTP
    # _response_.
    #
    def initialize(url,response)
      @url = url
      @response = response
      @doc = nil
    end

    #
    # Returns the response code from the page.
    #
    def code
      @response.code
    end

    #
    # Returns +true+ if the response code is 200, returns +false+ otherwise.
    #
    def is_ok?
      code == 200
    end

    #
    # Returns +true+ if the response code is 301 or 307, returns +false+
    # otherwise.
    #
    def is_redirect?
      (code == 301 || code == 307)
    end

    #
    # Returns +true+ if the response code is 308, returns +false+ otherwise.
    #
    def timedout?
      code == 308
    end

    #
    # Returns +true+ if the response code is 400, returns +false+ otherwise.
    #
    def bad_request?
      code == 400
    end

    #
    # Returns +true+ if the response code is 401, returns +false+ otherwise.
    #
    def is_unauthorized?
      code == 401
    end

    #
    # Returns +true+ if the response code is 403, returns +false+ otherwise.
    #
    def is_forbidden?
      code == 403
    end

    #
    # Returns +true+ if the response code is 404, returns +false+ otherwise.
    #
    def is_missing?
      code == 404
    end

    #
    # Returns +true+ if the response code is 500, returns +false+ otherwise.
    #
    def had_internal_server_error?
      code == 500
    end

    #
    # Returns the content-type of the page.
    #
    def content_type
      @response['Content-Type']
    end

    #
    # Returns +true+ if the page is a plain text document, returns +false+
    # otherwise.
    #
    def plain_text?
      (content_type =~ /text\/plain/) == 0
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

    #
    # Returns +true+ if the page is a MS Word document, returns +false+
    # otherwise.
    #
    def ms_word?
      (content_type =~ /application\/msword/) == 0
    end

    #
    # Returns +true+ if the page is a PDF document, returns +false+
    # otherwise.
    #
    def pdf?
      (content_type =~ /application\/pdf/) == 0
    end

    #
    # Returns +true+ if the page is a ZIP archive, returns +false+
    # otherwise.
    #
    def zip?
      (content_type =~ /application\/zip/) == 0
    end

    #
    # Returns the body of the page in +String+ form.
    #
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

    #
    # Returns all links from the HTML page.
    #
    def links
      if html?
        return doc.search('a[@href]').map do |a|
          a.attributes['href'].strip
        end
      end

      return []
    end

    #
    # Returns all links from the HtML page as absolute URLs.
    #
    def urls
      links.map { |link| to_absolute(link) }
    end

    protected

    #
    # Converts the specified _link_ into an absolute URL
    # based on the url of the page.
    #
    def to_absolute(link)
      # clean the link
      link = URI.encode(link.to_s.gsub(/#.*$/,''))

      relative = URI(link)
      return @url.merge(relative)
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
