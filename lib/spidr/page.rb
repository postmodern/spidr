require 'spidr/headers'
require 'spidr/body'
require 'spidr/links'

module Spidr
  #
  # Represents a requested page from a website.
  #
  class Page

    include Headers
    include Body
    include Links

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
    # The meta-redirect links of the page.
    #
    # @return [Array<String>]
    #   All meta-redirect links in the page.
    #
    # @deprecated
    #   Deprecated in 0.3.0 and will be removed in 0.4.0.
    #   Use {#meta_redirects} instead.
    #
    def meta_redirect
      STDERR.puts 'DEPRECATION: Spidr::Page#meta_redirect will be removed in 0.3.0'
      STDERR.puts 'DEPRECATION: Use Spidr::Page#meta_redirects instead'

      meta_redirects
    end

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
        header_name = name.to_s.sub('_','-')

        if @response.key?(header_name)
          return @response[header_name]
        end
      end

      return super(name,*arguments,&block)
    end
  
  end
end
