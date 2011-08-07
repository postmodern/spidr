require 'set'

module Spidr
  module Headers
    # Reserved names used within Cookie strings
    RESERVED_COOKIE_NAMES = Set['path', 'expires', 'domain']

    #
    # The response code from the page.
    #
    # @return [Integer]
    #   Response code from the page.
    #
    def code
      response.code.to_i
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
      (response['Content-Type'] || '')
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
      (headers['content-type'] || [])
    end

    #
    # The charset included in the Content-Type.
    #
    # @return [String, nil]
    #   The charset of the content.
    #
    # @since 0.4.0
    #
    def content_charset
      content_type.split(';').each do |param|
        if param.start_with?('charset=')
          return param.split('=',2).last
        end
      end

      return nil
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
    # Determines if the page is a Directory Listing.
    #
    # @return [Boolean]
    #   Specifies whether the page is a Directory Listing.
    #
    # @since 0.3.0
    #
    def directory?
      is_content_type?('text/directory')
    end

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
      is_content_type?('text/xml') || \
        is_content_type?('application/xml')
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
    # Determines if the page is JSON.
    #
    # @return [Boolean]
    #   Specifies whether the page is JSON.
    #
    # @since 0.3.0
    #
    def json?
      is_content_type?('application/json')
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
    # @since 0.2.7
    #
    def cookie
      (response['Set-Cookie'] || '')
    end

    alias raw_cookie cookie

    #
    # The Cookie values sent along with the page.
    #
    # @return [Array<String>]
    #   The Cookies from the response.
    #
    # @since 0.2.2
    #
    def cookies
      (headers['set-cookie'] || [])
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

          unless RESERVED_COOKIE_NAMES.include?(key)
            params[key] = (value || '')
          end
        end
      end

      return params
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
  end
end
