require 'set'

module Spidr
  class Agent
    # Common locations for Sitemap(s)
    COMMON_SITEMAP_LOCATIONS = %w[
      sitemap.xml
      sitemap.xml.gz
      sitemap.gz
      sitemap_index.xml
      sitemap-index.xml
      sitemap_index.xml.gz
      sitemap-index.xml.gz
    ].freeze

    #
    # Initializes the sitemap fetcher.
    #
    def initialize_sitemap
      @sitemap = true
    end

    #
    # Returns the URLs found as per the sitemap.xml spec.
    #
    # @return [Array<URI::HTTP>, Array<URI::HTTPS>]
    #   The URLs found.
    #
    # @see https://www.sitemaps.org/protocol.html
    def sitemap_urls(url)
      return [] unless @sitemap
      base_url = to_base_url(url)

      if @robots
        if urls = @robots.other_values(base_url)['Sitemap']
          return urls.flat_map { |u| get_sitemap_urls(url: u) }
        end
      end

      COMMON_SITEMAP_LOCATIONS.each do |path|
        if (page = get_page("#{base_url}/#{path}")).code == 200
          return get_sitemap_urls(page: page)
        end
      end

      []
    end

    private

    def get_sitemap_urls(url: nil, page: nil)
      page = get_page(url) if page.nil?
      return [] unless page

      if page.sitemap_index?
        page.each_sitemap_index_url.flat_map { |u| get_sitemap_urls(url: u) }
      else
        page.sitemap_urls
      end
    end

    def to_base_url(url)
      uri = url
      uri = URI.parse(url) unless url.is_a?(URI)

      "#{uri.scheme}://#{uri.host}"
    end
  end
end
