require 'spidr/extensions/uri'
require 'uri'

module Spidr
  module Links
    include Enumerable

    #
    # Enumerates over the meta-redirect links in the page.
    #
    # @yield [link]
    #   If a block is given, it will be passed every meta-redirect link
    #   from the page.
    #
    # @yieldparam [String] link
    #   A meta-redirect link from the page.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator object will be returned.
    #
    # @since 0.3.0
    #
    def each_meta_redirect
      return enum_for(:each_meta_redirect) unless block_given?

      if (html? && doc)
        search('//meta[@http-equiv and @content]').each do |node|
          if node.get_attribute('http-equiv') =~ /refresh/i
            content = node.get_attribute('content')

            if (redirect = content.match(/url=(\S+)$/))
              yield redirect[1]
            end
          end
        end
      end
    end

    #
    # Returns a boolean indicating whether or not page-level meta
    # redirects are present in this page.
    #
    # @return [Boolean]
    #   Specifies whether the page includes page-level redirects.
    #
    def meta_redirect?
      !(each_meta_redirect.first.nil?)
    end

    #
    # The meta-redirect links of the page.
    #
    # @return [Array<String>]
    #   All meta-redirect links in the page.
    #
    # @since 0.3.0
    #
    def meta_redirects
      each_meta_redirect.to_a
    end

    #
    # Enumerates over every HTTP or meta-redirect link in the page.
    #
    # @yield [link]
    #   The given block will be passed every redirection link from the page.
    #
    # @yieldparam [String] link
    #   A HTTP or meta-redirect link from the page.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator object will be returned.
    #
    # @since 0.3.0
    #
    def each_redirect(&block)
      return enum_for(:each_redirect) unless block

      location = headers['location']

      if location.nil?
        # check page-level meta redirects if there isn't a location header
        each_meta_redirect(&block)
      elsif location.kind_of?(Array)
        location.each(&block)
      else
        # usually the location header contains a single String
        yield location
      end
    end

    #
    # URLs that this document redirects to.
    #
    # @return [Array<String>]
    #   The links that this page redirects to (usually found in a
    #   location header or by way of a page-level meta redirect).
    #
    def redirects_to
      each_redirect.to_a
    end

    #
    # Enumerates over every link in the page.
    #
    # @yield [link]
    #   The given block will be passed every non-empty link in the page.
    #
    # @yieldparam [String] link
    #   A link in the page.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator object will be returned.
    #
    # @since 0.3.0
    #
    def each_link
      return enum_for(:each_link) unless block_given?

      filter = lambda { |url|
        yield url unless (url.nil? || url.empty?)
      }

      each_redirect(&filter) if is_redirect?

      if (html? && doc)
        doc.search('//a[@href]').each do |a|
          filter.call(a.get_attribute('href'))
        end

        doc.search('//frame[@src]').each do |iframe|
          filter.call(iframe.get_attribute('src'))
        end

        doc.search('//iframe[@src]').each do |iframe|
          filter.call(iframe.get_attribute('src'))
        end

        doc.search('//link[@href]').each do |link|
          filter.call(link.get_attribute('href'))
        end

        doc.search('//script[@src]').each do |script|
          filter.call(script.get_attribute('src'))
        end
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
      each_link.to_a
    end

    #
    # Enumerates over every absolute URL in the page.
    #
    # @yield [url]
    #   The given block will be passed every URL in the page.
    #
    # @yieldparam [URI::HTTP] url
    #   An absolute URL in the page.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator object will be returned.
    #
    # @since 0.3.0
    #
    def each_url
      return enum_for(:each_url) unless block_given?

      each_link do |link|
        if (url = to_absolute(link))
          yield url
        end
      end
    end

    alias each each_url

    #
    # Absolute URIs from within the page.
    #
    # @return [Array<URI::HTTP>]
    #   The links from within the page, converted to absolute URIs.
    #
    def urls
      each_url.to_a
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
        new_url = url.merge(link.to_s)
      rescue Exception
        return nil
      end

      # do not handle FTP
      if url.scheme == 'ftp'
        return nil
      end

      if new_url.path
        path = new_url.path

        # ensure that paths begin with a leading '/' for URI::FTP
        if (new_url.scheme == 'ftp' && path[0,1] != '/')
          path.insert(0,'/')
        end

        # make sure the path does not contain any .. or . directories,
        # since URI::Generic#merge cannot normalize paths such as
        # "/stuff/../"
        new_url.path = URI.expand_path(path)
      end

      return new_url
    end
  end
end
