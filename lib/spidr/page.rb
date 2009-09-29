require 'uri'
require 'nokogiri'

module Spidr
  class Page

    # URL of the page
    attr_reader :url

    # HTTP Response
    attr_reader :response

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
      @headers = response.to_hash
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
    # If the page has a <tt>text/html</tt> content-type, a
    # Nokogiri::HTML::Document object will be returned. If the page has a
    # <tt>text/xml</tt> content-type, a Nokogiri::XML::Document object
    # will be returned. Other content-types will cause +nil+ to be
    # returned.
    #
    def doc
      return nil if (body.nil? || body.empty?)

      begin
        if html?
          return @doc ||= Nokogiri::HTML(body)
        elsif xml?
          return @doc ||= Nokogiri::XML(body)
        end
      rescue
        return nil
      end
    end

    #
    # Searches the document for XPath or CSS Path paths, with an optional
    # Hash of namespaces may be appended. Returns +[]+ if nothing could be
    # found, or if the page does not have either a +text/html+ or
    # +text/xml+ content-type.
    #
    #   page.search('//a[@href]')
    #
    def search(*paths)
      if doc
        return doc.search(*paths)
      end

      return []
    end

    #
    # Searches for the first occurrence an XPath or CSS Path expression.
    # Returns +nil+ if nothing could be found, or if the page does not have
    # either a +text/html+ or +text/xml+ content-type.
    #
    #   page.at('//title')
    #
    def at(*arguments)
      if doc
        return doc.at(*arguments)
      end

      return nil
    end

    alias / search
    alias % at

    #
    # Returns all links from the HTML page.
    #
    def links
      urls = []

      add_url = lambda { |url|
        urls << url unless (url.nil? || url.empty?)
      }

      case code
      when 300..303, 307
        location = @headers['location']

        if location.kind_of?(Array)
          # handle multiple location URLs
          location.each(&add_url)
        else
          # usually the location header contains a single String
          add_url.call(location)
        end
      end

      if (html? && doc)
        doc.search('a[@href]').each do |a|
          add_url.call(a.get_attribute('href'))
        end

        doc.search('frame[@src]').each do |iframe|
          add_url.call(iframe.get_attribute('src'))
        end

        doc.search('iframe[@src]').each do |iframe|
          add_url.call(iframe.get_attribute('src'))
        end
      end

      return urls
    end

    #
    # Returns all links from the HtML page as absolute URLs.
    #
    def urls
      links.map { |link| to_absolute(link) }.compact
    end

    protected

    #
    # Converts the specified _link_ into an absolute URL
    # based on the url of the page.
    #
    def to_absolute(link)
      # decode, clean then re-encode the URL
      link = URI.encode(URI.decode(link.to_s).gsub(/#[a-zA-Z0-9_-]*$/,''))

      begin
        relative = URI(link)
        absolute = @url.merge(relative)

        if absolute.path
          if absolute.path.empty?
            # default the absolute path to '/'
            absolute.path = '/'
          else
            # make sure the path does not contain any .. or . directories.
            absolute.path = File.expand_path(absolute.path)
          end
        end

        return absolute
      rescue URI::InvalidURIError => e
        return nil
      end
    end

    #
    # Provides transparent access to the values in the +headers+ +Hash+.
    #
    def method_missing(sym,*args,&block)
      if (args.empty? && block.nil?)
        name = sym.id2name.sub('_','-')

        return @response[name] if @response.key?(name)
      end

      return super(sym,*args,&block)
    end

  end
end
