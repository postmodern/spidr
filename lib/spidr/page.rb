require 'spidr/extensions/uri'

require 'set'
require 'uri'
require 'nokogiri'

module Spidr
  #
  # Represents a requested page from a website.
  #
  class Page

    # Reserved names used within Cookie strings
    RESERVED_COOKIE_NAMES = Set['path', 'expires', 'domain']

    # URL of the page
    attr_reader :url

    # HTTP Response
    attr_reader :response

    # Headers returned with the body
    attr_reader :headers

    #
    # Creates a new Page object.
    #
    # @param [URI::HTTP] url
    #   The URL of the page.
    #
    # @param [Net::HTTP::Response] response
    #   The response from the request for the page.
    #
    def initialize(url,response)
      @url = url
      @response = response
      @headers = response.to_hash
      @doc = nil
    end

    #
    # The response code from the page.
    #
    # @return [Integer]
    #   Response code from the page.
    #
    def code
      @response.code.to_i
    end

    #
    # Determines if the response code is `200`.
    #
    # @return [Boolean]
    #   Specifies whether the response code is `200`.
    #
    def is_ok?
      code == 200
    end

    alias ok? is_ok?

    #
    # Determines if the response code is `300`, `301`, `302`, `303`
    # or `307`. Also checks for "soft" redirects added at the page 
    # level by a meta refresh tag.
    #
    # @return [Boolean]
    #   Specifies whether the response code is a HTTP Redirect code.
    #
    def is_redirect?
      case code
      when 300..303, 307
        true
      when 200
        meta_redirect?
      else
        false
      end
    end

    alias redirect? is_redirect?

    #
    # Determines if the response code is `308`.
    #
    # @return [Boolean]
    #   Specifies whether the response code is `308`.
    #
    def timedout?
      code == 308
    end

    #
    # Determines if the response code is `400`.
    #
    # @return [Boolean]
    #   Specifies whether the response code is `400`.
    #
    def bad_request?
      code == 400
    end

    #
    # Determines if the response code is `401`.
    #
    # @return [Boolean]
    #   Specifies whether the response code is `401`.
    #
    def is_unauthorized?
      code == 401
    end

    alias unauthorized? is_unauthorized?

    #
    # Determines if the response code is `403`.
    #
    # @return [Boolean]
    #   Specifies whether the response code is `403`.
    #
    def is_forbidden?
      code == 403
    end

    alias forbidden? is_forbidden?

    #
    # Determines if the response code is `404`.
    #
    # @return [Boolean]
    #   Specifies whether the response code is `404`.
    #
    def is_missing?
      code == 404
    end

    alias missing? is_missing?

    #
    # Determines if the response code is `500`.
    #
    # @return [Boolean]
    #   Specifies whether the response code is `500`.
    #
    def had_internal_server_error?
      code == 500
    end

    #
    # The Content-Type of the page.
    #
    # @return [String]
    #   The Content-Type of the page.
    #
    def content_type
      (@response['Content-Type'] || '')
    end

    #
    # The content types of the page.
    #
    # @return [Array<String>]
    #   The values within the Content-Type header.
    #
    # @since 0.2.2
    #
    def content_types
      (@headers['content-type'] || [])
    end

    #
    # Determines if the page is plain-text.
    #
    # @return [Boolean]
    #   Specifies whether the page is plain-text.
    #
    def plain_text?
      is_content_type?('text/plain')
    end

    alias txt? plain_text?

    #
    # Determines if the page is HTML document.
    #
    # @return [Boolean]
    #   Specifies whether the page is HTML document.
    #
    def html?
      is_content_type?('text/html')
    end

    #
    # Determines if the page is XML document.
    #
    # @return [Boolean]
    #   Specifies whether the page is XML document.
    #
    def xml?
      is_content_type?('text/xml')
    end

    #
    # Determines if the page is XML Stylesheet (XSL).
    #
    # @return [Boolean]
    #   Specifies whether the page is XML Stylesheet (XSL).
    #
    def xsl?
      is_content_type?('text/xsl')
    end

    #
    # Determines if the page is JavaScript.
    #
    # @return [Boolean]
    #   Specifies whether the page is JavaScript.
    #
    def javascript?
      is_content_type?('text/javascript') || \
        is_content_type?('application/javascript')
    end

    #
    # Determines if the page is a CSS stylesheet.
    #
    # @return [Boolean]
    #   Specifies whether the page is a CSS stylesheet.
    #
    def css?
      is_content_type?('text/css')
    end

    #
    # Determines if the page is a RSS feed.
    #
    # @return [Boolean]
    #   Specifies whether the page is a RSS feed.
    #
    def rss?
      is_content_type?('application/rss+xml') || \
        is_content_type?('application/rdf+xml')
    end

    #
    # Determines if the page is an Atom feed.
    #
    # @return [Boolean]
    #   Specifies whether the page is an Atom feed.
    #
    def atom?
      is_content_type?('application/atom+xml')
    end

    #
    # Determines if the page is a MS Word document.
    #
    # @return [Boolean]
    #   Specifies whether the page is a MS Word document.
    #
    def ms_word?
      is_content_type?('application/msword')
    end

    #
    # Determines if the page is a PDF document.
    #
    # @return [Boolean]
    #   Specifies whether the page is a PDF document.
    #
    def pdf?
      is_content_type?('application/pdf')
    end

    #
    # Determines if the page is a ZIP archive.
    #
    # @return [Boolean]
    #   Specifies whether the page is a ZIP archive.
    #
    def zip?
      is_content_type?('application/zip')
    end

    #
    # The raw Cookie String sent along with the page.
    #
    # @return [String]
    #   The raw Cookie from the response.
    #
    # @since 0.2.2
    #
    def cookie
      (@response['Set-Cookie'] || '')
    end

    #
    # The Cookie values sent along with the page.
    #
    # @return [Array<String>]
    #   The Cookies from the response.
    #
    # @since 0.2.2
    #
    def cookies
      (@headers['set-cookie'] || [])
    end

    #
    # The Cookie key -> value pairs returned with the response.
    #
    # @return [Hash{String => String}]
    #   The cookie keys and values.
    #
    # @since 0.2.2
    #
    def cookie_params
      params = {}

      cookies.each do |cookie|
        cookie.split('; ').each do |key_value|
          key, value = key_value.split('=',2)

          next if RESERVED_COOKIE_NAMES.include?(key)

          params[key] = (value || '')
        end
      end

      return params
    end

    #
    # The body of the response.
    #
    # @return [String]
    #   The body of the response.
    #
    def body
      (@response.body || '')
    end

    #
    # Returns a parsed document object for HTML, XML, RSS and Atom pages.
    #
    # @return [Nokogiri::HTML::Document, Nokogiri::XML::Document, nil]
    #   The document that represents HTML or XML pages.
    #   Returns `nil` if the page is neither HTML, XML, RSS, Atom or if
    #   the page could not be parsed properly.
    #
    # @see http://nokogiri.rubyforge.org/nokogiri/Nokogiri/XML/Document.html
    # @see http://nokogiri.rubyforge.org/nokogiri/Nokogiri/HTML/Document.html
    #
    def doc
      return nil if body.empty?

      begin
        if html?
          return @doc ||= Nokogiri::HTML(body)
        elsif (xml? || xsl? || rss? || atom?)
          return @doc ||= Nokogiri::XML(body)
        end
      rescue
        return nil
      end
    end

    #
    # Searches the document for XPath or CSS Path paths.
    #
    # @param [Array<String>] paths
    #   CSS or XPath expressions to search the document with.
    #
    # @return [Array]
    #   The matched nodes from the document.
    #   Returns an empty Array if no nodes were matched, or if the page
    #   is not an HTML or XML document.
    #
    # @example
    #   page.search('//a[@href]')
    #
    # @see http://nokogiri.rubyforge.org/nokogiri/Nokogiri/XML/Node.html#M000239
    #
    def search(*paths)
      if doc
        doc.search(*paths)
      else
        []
      end
    end

    #
    # Searches for the first occurrence an XPath or CSS Path expression.
    #
    # @return [Nokogiri::HTML::Node, Nokogiri::XML::Node, nil]
    #   The first matched node. Returns `nil` if no nodes could be matched,
    #   or if the page is not a HTML or XML document.
    #
    # @example
    #   page.at('//title')
    #
    # @see http://nokogiri.rubyforge.org/nokogiri/Nokogiri/XML/Node.html#M000251
    #
    def at(*arguments)
      if doc
        doc.at(*arguments)
      end
    end

    alias / search
    alias % at

    #
    # The title of the HTML page.
    #
    # @return [String]
    #   The inner-text of the title element of the page.
    #
    def title
      if (node = at('//title'))
        node.inner_text
      end
    end

    #
    # The links from within the page.
    #
    # @return [Array<String>]
    #   All links within the HTML page, frame/iframe source URLs and any
    #   links in the `Location` header.
    #
    def links
      urls = []

      add_url = lambda { |url|
        urls << url unless (url.nil? || url.empty?)
      }

      self.redirects_to.each(&add_url) if self.is_redirect?

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

        doc.search('link[@href]').each do |link|
          add_url.call(link.get_attribute('href'))
        end

        doc.search('script[@src]').each do |script|
          add_url.call(script.get_attribute('src'))
        end
      end

      return urls
    end

    #
    # URL(s) that this document redirects to.
    #
    # @return [Array<String>]
    #   The links that this page redirects to (usually found in a
    #   location header or by way of a page-level meta redirect).
    #
    def redirects_to
      location = @headers['location']

      if location.nil?
        # check page-level meta redirects if there isn't a location header
        meta_redirect
      elsif location.kind_of?(Array)
        location
      else
        # usually the location header contains a single String
        [location]
      end
    end

    #
    # Absolute URIs from within the page.
    #
    # @return [Array<URI::HTTP>]
    #   The links from within the page, converted to absolute URIs.
    #
    def urls
      links.map { |link| to_absolute(link) }.compact
    end

    #
    # Normalizes and expands a given link into a proper URI.
    #
    # @param [String] link
    #   The link to normalize and expand.
    #
    # @return [URI::HTTP]
    #   The normalized URI.
    #
    def to_absolute(link)
      begin
        url = @url.merge(link.to_s)
      rescue URI::InvalidURIError
        return nil
      end

      unless (url.path.nil? || url.path.empty?)
        # make sure the path does not contain any .. or . directories,
        # since URI::Generic#merge cannot normalize paths such as
        # "/stuff/../"
        url.path = URI.expand_path(url.path)
      end

      return url
    end

    #
    # Determines if a page-level "soft" redirect is present. If yes,
    # returns an array of those redirects (usually a single URL).
    # Otherwise, returns false.
    #
    # @return [Array<String>]
    #   An array of redirect URLs
    #
    def meta_redirect
      redirects = []

      if (html? && doc)
        search('//meta[@http-equiv and @content]').each do |node|
          if node.get_attribute('http-equiv') =~ /refresh/i
            content = node.get_attribute('content')

            if (redirect = content.match(/url=(\S+)$/))
              redirects << redirect[1]
            end
          end
        end
      end

      return redirects.uniq
    end

    #
    # Returns a boolean indicating whether or not page-level meta
    # redirects are present in this page.
    #
    # @return [Boolean]
    #   Specifies whether the page includes page-level redirects.
    #
    def meta_redirect?
      !meta_redirect.empty?
    end

    protected

    #
    # Determines if any of the content-types of the page include a given
    # type.
    #
    # @param [String] type
    #   The content-type to test for.
    #
    # @return [Boolean]
    #   Specifies whether the page includes the given content-type.
    #
    # @since 0.2.4
    #
    def is_content_type?(type)
      content_types.any? { |content| content.include?(type) }
    end

    #
    # Provides transparent access to the values in `headers`.
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
