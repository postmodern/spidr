require 'open-uri'
require 'json'

module Helpers
  module Course
    COURSE_URL = URI('http://spidr.rubyforge.org/course/start.html')

    SPECS_URL = 'http://spidr.rubyforge.org/course/specs.json'

    def self.included(base)
      specs = JSON.parse(open(SPECS_URL).read)

      if specs.kind_of?(Array)
        specs.each do |spec|
          if spec['behavior'] == 'follow'
            base.module_eval %{
              it #{spec['message'].to_s.dump} do
                visited_link?(#{spec['link'].to_s.dump})
              end
            }
          else
            base.module_eval %{
              it #{spec['message'].to_s.dump} do
                !(visited_link?(#{spec['link'].to_s.dump}))
              end
            }
          end
        end
      end
    end

    #
    # Returns +true+ if the agent has visited the specified _link_, returns
    # +false+ otherwise.
    #
    def visited_link?(link)
      url = COURSE_URL.merge(URI.encode(link))

      @agent.visited_urls.each do |visited_url|
        return true if visited_url == url
      end

      return false
    end
  end
end
