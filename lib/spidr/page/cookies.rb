require 'set'

module Spidr
  class Page
    # Reserved names used within Cookie strings
    RESERVED_COOKIE_NAMES = Set['path', 'expires', 'domain']

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

      cookies.each do |value|
        value.split(';').each do |param|
          param.strip!

          name, value = param.split('=',2)

          unless RESERVED_COOKIE_NAMES.include?(name)
            params[name] = (value || '')
          end
        end
      end

      return params
    end
  end
end
