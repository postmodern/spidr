# frozen_string_literal: true

require 'uri'

module Spidr
  class Agent

    # Specifies whether the Agent will strip URI fragments
    attr_accessor :strip_fragments

    # Specifies whether the Agent will strip URI queries
    attr_accessor :strip_query

    #
    # Sanitizes a URL based on filtering options.
    #
    # @param [URI::HTTP, URI::HTTPS, String] url
    #   The URL to be sanitized
    #
    # @return [URI::HTTP, URI::HTTPS]
    #   The new sanitized URL.
    #
    # @since 0.2.2
    #
    def sanitize_url(url)
      url = URI(url)

      url.fragment = nil if @strip_fragments
      url.query    = nil if @strip_query

      return url
    end

    protected

    #
    # Initializes the Sanitizer rules.
    #
    # @param [Boolean] strip_fragments
    #   Specifies whether or not to strip the fragment component from URLs.
    #
    # @param [Boolean] strip_query
    #   Specifies whether or not to strip the query component from URLs.
    #
    # @since 0.2.2
    #
    def initialize_sanitizers(strip_fragments: true, strip_query: false)
      @strip_fragments = strip_fragments
      @strip_query     = strip_query
    end

  end
end
