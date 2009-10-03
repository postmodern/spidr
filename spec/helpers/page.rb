require 'net/http'
require 'uri'

def get_page(url)
  url = URI(url.to_s)

  return Spidr::Page.new(url,Net::HTTP.get_response(url))
end
