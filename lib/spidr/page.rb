module Spidr
  #
  # Represents a requested page from a website.
  #
  class Page

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
    # @param [Net::HTTPResponse] response
    #   The response from the request for the page.
    #
    def initialize(url,response)
      @url      = url
      @response = response
      @headers  = response.to_hash
      @doc      = nil
    end

    #
    # The body of the response.
    #
    # @return [String]
    #   The body of the response.
    #
    def body
      (response.body || '')
    end

    alias to_s body

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
      unless body.empty?
        doc_class = if html?
                      Nokogiri::HTML::Document
                    elsif rss? || atom? || xml? || xsl?
                      Nokogiri::XML::Document
                    end

        if doc_class
          begin
            @doc ||= doc_class.parse(body, @url.to_s, content_charset)
          rescue
          end
        end
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

    protected

    #
    # Provides transparent access to the values in {#headers}.
    #
    # @param [Symbol] name
    #   The name of the missing method.
    #
    # @param [Array] arguments
    #   Additional arguments for the missing method.
    #
    # @return [String]
    #   The missing method mapped to a header in {#headers}.
    #
    # @raise [NoMethodError]
    #   The missing method did not map to a header in {#headers}.
    #
    def method_missing(name,*arguments,&block)
      if (arguments.empty? && block.nil?)
        header_name = name.to_s.tr('_','-')

        if @response.key?(header_name)
          return @response[header_name]
        end
      end

      return super(name,*arguments,&block)
    end

  end
end

require 'spidr/page/status_codes'
require 'spidr/page/content_types'
require 'spidr/page/cookies'
require 'spidr/page/html'
require 'spidr/page/sitemap'
