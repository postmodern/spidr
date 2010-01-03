require 'wsoc/config'
require 'open-uri'
require 'json'

require 'helpers/history'

module Helpers
  module WSOC
    include History

    SERVER_URL = URI::HTTP.build(
      :host => (ENV['HOST'] || ::WSOC::Config::DEFAULT_HOST),
      :port => (ENV['PORT'] || ::WSOC::Config::DEFAULT_PORT)
    )

    SPECS_URL = SERVER_URL.merge(::WSOC::Config::SPECS_PATHS[:json])

    COURSE_URL = SERVER_URL.merge(::WSOC::Config::COURSE_START_PATH)

    COURSE_METADATA = {}

    def self.included(base)
      hash = JSON.parse(open(SPECS_URL).read)
      metadata = hash['metadata']
      specs = hash['specs']
      puts "METADATA? #{metadata}"

      if metadata.kind_of?(Hash)
        COURSE_METADATA.merge!(metadata)
      end

      if specs.kind_of?(Array)
        specs.each do |spec|
          message = spec['message'].dump
          url = spec['url'].dump

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

    def course
      WSOC::COURSE_METADATA
    end

    def run_course
      Agent.start_at(COURSE_URL) do |agent|
        agent.authorized << { :username => course['auth_user'], :password => course['auth_password'] }
        agent.every_failed_url { |url| puts "[FAILED] #{url}" }
        agent.every_url { |url| puts url }
      end
    end
  end
end
