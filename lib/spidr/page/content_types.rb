module Spidr
  class Page
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
      (@response.get_fields('content-type') || [])
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
      content_types.each do |value|
        if value.include?(';')
          value.split(';').each do |param|
            param.strip!

            if param.start_with?('charset=')
              return param.split('=',2).last
            end
          end
        end
      end

      return nil
    end

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
    # @example Match the Content-Type
    #   page.is_content_type?('application/json')
    #
    # @example Match the sub-type of the Content-Type
    #   page.is_content_type?('json')
    #
    # @since 0.4.0
    #
    def is_content_type?(type)
      if type.include?('/')
        # otherwise only match the first param
        content_types.any? do |value|
          value = value.split(';',2).first

          value == type
        end
      else
        # otherwise only match the sub-type
        content_types.any? do |value|
          value = value.split(';',2).first
          value = value.split('/',2).last

          value == type
        end
      end
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
  end
end
