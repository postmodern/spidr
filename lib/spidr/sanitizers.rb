require 'uri'

module Spidr
  module Sanitizers
    def self.included(base)
      base.module_eval do
        # Specifies whether the Agent will strip URI fragments
        attr_accessor :strip_fragments

        # Specifies whether the Agent will strip URI queries
        attr_accessor :strip_query
      end
    end

    #
    # Initializes the sanitization rules.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [Boolean] :strip_fragments (true)
    #   Specifies whether or not to strip the fragment component from URLs.
    #
    # @option options [Boolean] :strip_query (false)
    #   Specifies whether or not to strip the query component from URLs.
    #
    def initialize(options={})
      @strip_fragments = true
      
      if options.has_key?(:strip_fragments)
        @strip_fragments = options[:strip_fragments]
      end

      @strip_query = (options[:strip_query] || false)
    end

    #
    # Sanitizes a URL based on filtering options.
    #
    # @param [URI::HTTP, URI::HTTPS, String] url
    #   The URL to be sanitized
    #
    # @return [URI::HTTP, URI::HTTPS]
    #   The new sanitized URL.
    #
    def sanitize_url(url)
      url = URI(url.to_s)

      url.fragment = nil if @strip_fragments
      url.query = nil if @strip_query

      return url
    end
  end
end
