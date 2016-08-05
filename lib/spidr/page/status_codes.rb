module Spidr
  class Page
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
  end
end
