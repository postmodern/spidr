require 'nokogiri'
require 'zlib'

module Spidr
  class Page
    include Enumerable

    #
    # Enumerates over the links in the sitemap page.
    #
    # @yield [link]
    #   If a block is given, it will be passed every link in the
    #   sitemap page.
    #
    # @yieldparam [String] link
    #   A URL from the sitemap page.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator object will be returned.
    def each_sitemap_link
      return enum_for(__method__) unless block_given?

      each_extracted_sitemap_links('url') { |url| yield(url) }
    end

    #
    # Return all links defined in Sitemap.
    #
    # @return [Array<String>]
    #   of links defined in Sitemap.
    def sitemap_links
      each_sitemap_link.to_a
    end

    #
    # Enumerates over the Sitemap index links in the sitemap page.
    #
    # @yield [link]
    #   If a block is given, it will be passed every link in the
    #   sitemap page.
    #
    # @yieldparam [String] link
    #   A URL from the sitemap page.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator object will be returned.
    def each_sitemap_index_link
      return enum_for(__method__) unless block_given?

      each_extracted_sitemap_links('sitemap') { |url| yield(url) }
    end

    #
    # Return all Sitemap index links defined in sitemap.
    #
    # @return [Array<String>]
    #   of links defined in Sitemap.
    def sitemap_index_links
      each_sitemap_index_link.to_a
    end

    #
    # Enumerates over the URLs in the sitemap page.
    #
    # @yield [url]
    #   If a block is given, it will be passed every URL in the
    #   sitemap page.
    #
    # @yieldparam [URI::HTTP, URI::HTTPS] url
    #   A URL from the sitemap page.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator object will be returned.
    def each_sitemap_url
      return enum_for(__method__) unless block_given?

      each_sitemap_link do |link|
        if (url = to_absolute(link))
          yield url
        end
      end
    end

    #
    # Return all URLs defined in Sitemap.
    #
    # @return [Array<URI::HTTP>, Array<URI::HTTPS>]
    #   of URLs defined in Sitemap.
    def sitemap_urls
      each_sitemap_url.to_a
    end

    #
    # Enumerates over the sitemap URLs in the sitemap page.
    #
    # @yield [url]
    #   If a block is given, it will be passed every sitemap URL in the
    #   sitemap page.
    #
    # @yieldparam [URI::HTTP, URI::HTTPS] url
    #   A sitemap URL from the sitemap page.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator object will be returned.
    def each_sitemap_index_url
      return enum_for(__method__) unless block_given?

      each_sitemap_index_link do |link|
        if (url = to_absolute(link))
          yield url
        end
      end
    end

    #
    # Return all sitemap index URLs defined in Sitemap.
    #
    # @return [Array<URI::HTTP>, Array<URI::HTTPS>]
    #   Sitemap index URLs defined in Sitemap.
    def sitemap_index_urls
      each_sitemap_index_url.to_a
    end

    #
    # Returns true if Sitemap is a Sitemap index.
    #
    # @return [Boolean]
    def sitemap_index?
      sitemap_root_name == 'sitemapindex'
    end

    #
    # Returns true if Sitemap is a regular list of URLs.
    #
    # @return [Boolean]
    def sitemap_urlset?
      sitemap_root_name == 'urlset'
    end

    #
    # Returns the document for the sitemap, if the content type is gzip it
    # will be uncompressed.
    #
    # @return [Nokogiri::HTML::Document, Nokogiri::XML::Document, nil]
    #   The document that represents sitemap XML pages.
    #   Returns `nil` if the page is neither XML, gzipped XML or if
    #   the page could not be parsed properly.
    #
    # @see #doc
    #
    def sitemap_doc
      return doc if doc && !gzip?

      begin
        @sitemap_doc ||= Nokogiri::XML::Document.parse(unzipped_body, @url.to_s, content_charset)
      rescue
      end
    end

    private

    def sitemap_root_name
      return unless doc.root

      doc.root.name
    end

    def each_extracted_sitemap_links(node_name)
      if plain_text?
        return unzipped_body.each_line { |url| yield(url.strip) }
      end

      return unless sitemap_doc

      sitemap_doc.css("#{node_name} loc").each do |element|
        yield(element.text)
      end
    end

    def unzipped_body
      return body unless gzip?

      io = StringIO.new(body)
      gz = Zlib::GzipReader.new(io)
      body = gz.read
    rescue Zlib::Error
      ''
    ensure
      gz.close if gz

      body
    end
  end
end
