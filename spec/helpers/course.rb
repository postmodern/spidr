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
          url = spec['url'].to_s.dump

          case spec['behavior']
          when 'follow'
            base.module_eval %{
              it #{message} do
                should_visit_link(#{url})
              end
            }
          when 'nofollow'
            base.module_eval %{
              it #{message} do
                should_visit_once(#{url})
              end
            }
          when 'fail'
            base.module_eval %{
              it #{message} do
                should_fail_link(#{url})
              end
            }
          else
            link = spec['link'].to_s.dump

            base.module_eval %{
              it #{message} do
                should_ignore_link(#{link})
                should_ignore_link(#{url})
              end
            }
          end
        end
      end
    end

    def run_course
      Agent.start_at(COURSE_URL,:hosts => [COURSE_URL.host]) do |agent|
        agent.every_failed_url { |url| puts "[FAILED] #{url}" }
        agent.every_url { |url| puts url }
      end
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
      @agent.visited?(COURSE_URL.merge(URI.encode(link)))
    end

    def visit_failed?(link)
      @agent.failed?(COURSE_URL.merge(URI.encode(link)))
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

    def should_fail_link(link)
      visited_link?(link).should == false
      visit_failed?(link).should == true
    end
  end
end
