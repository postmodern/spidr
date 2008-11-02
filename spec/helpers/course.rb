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
          message = spec['message'].to_s.dump
          link = spec['link'].to_s.dump

          if spec['behavior'] == 'follow'
            base.module_eval %{
              it #{message} do
                should_visit_link(#{link})
              end
            }
          elsif spec['behavior'] == 'nofollow'
            base.module_eval %{
              it #{message} do
                should_visit_once(#{link})
              end
            }
          else
            base.module_eval %{
              it #{message} do
                should_ignore_link(#{link})
              end
            }
          end
        end
      end
    end

    def run_course
      Agent.start_at(COURSE_URL,:hosts => [COURSE_URL.host])
    end

    def visited_once?(link)
      url = COURSE_URL.merge(URI.encode(link))

      return @agent.visited_urls.select { |visited_url|
        visited_url == url
      }.length == 1
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

    def should_visit_link(link)
      visited_link?(link).should == true
    end

    def should_ignore_link(link)
      visited_link?(link).should == false
    end

    def should_visit_once(link)
      visited_once?(link).should == true
    end
  end
end
