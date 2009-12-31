require 'wsoc/config'
require 'open-uri'
require 'json'

module Helpers
  module WSOC
    SERVER_URL = URI::HTTP.build(
      :host => (ENV['HOST'] || ::WSOC::Config::DEFAULT_HOST),
      :port => (ENV['PORT'] || ::WSOC::Config::DEFAULT_PORT)
    )

    SPECS_URL = SERVER_URL.merge(::WSOC::Config::SPECS_PATHS[:json])

    COURSE_URL = SERVER_URL.merge(::WSOC::Config::COURSE_START_PATH)

    def self.included(base)
      specs = JSON.parse(open(SPECS_URL).read)

      if specs.kind_of?(Array)
        specs.each do |spec|
          message = spec['message'].dump
          url = URI.encode(spec['url']).dump

          case spec['behavior']
          when 'visit'
            base.module_eval %{
              it #{message} do
                should_visit_link(#{url})
              end
            }
          when 'ignore'
            base.module_eval %{
              it #{message} do
                should_ignore_link(#{url})
              end
            }
          when 'fail'
            base.module_eval %{
              it #{message} do
                should_fail_link(#{url})
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

    def visited_once?(url)
      return @agent.visited_urls.select { |visited_url|
        visited_url == url
      }.length == 1
    end

    def visited_link?(url)
      @agent.visited?(url)
    end

    def visit_failed?(url)
      @agent.failed?(url)
    end

    def should_visit_link(url)
      visited_link?(url).should == true
    end

    def should_ignore_link(url)
      visited_link?(url).should == false
    end

    def should_visit_once(url)
      visited_once?(url).should == true
    end

    def should_fail_link(url)
      visited_link?(url).should == false
      visit_failed?(url).should == true
    end
  end
end
