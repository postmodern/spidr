require 'nokogiri'
require 'json'

namespace :course do
  COURSE_URL = URI('http://spidr.rubyforge.org/course/')

  STATIC_DIR = File.expand_path(File.join(File.dirname(__FILE__),'..','static'))

  COURSE_DIR = File.join(STATIC_DIR,'course')

  desc "Build the JSON specs file for the course"
  task :specs do
    File.open(File.join(COURSE_DIR,'specs.json'),'w') do |file|
      specs = []

      Dir[File.join(COURSE_DIR,'**','*.html')].each do |page|
        doc = Nokogiri::HTML(open(page))
        page_url = COURSE_URL.merge(page.sub(STATIC_DIR,''))

        link_to_spec = lambda { |link,spec_data|
          relative_url = (link.get_attribute('href') || '')
          absolute_url = page_url.merge(URI.encode(relative_url))

          if absolute_url.path
            absolute_url.path = File.expand_path(absolute_url.path)
          end

          spec_data.merge(
            :message => link.inner_text,
            :link => relative_url,
            :url => absolute_url,
            :example => link.to_html
          )
        }

        doc.search('.follow//a').each do |follow|
          specs << link_to_spec.call(follow, :behavior => :follow)
        end

        doc.search('.nofollow//a').each do |nofollow|
          specs << link_to_spec.call(nofollow, :behavior => :nofollow)
        end

        doc.search('.ignore//a').each do |ignore|
          specs << link_to_spec.call(ignore, :behavior => :ignore)
        end

        doc.search('.fail//a').each do |ignore|
          specs << link_to_spec.call(ignore, :behavior => :fail)
        end
      end

      file.write(specs.to_json)
    end
  end
end
