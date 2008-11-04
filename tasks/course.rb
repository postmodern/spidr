require 'hpricot'
require 'json'

namespace :course do
  COURSE_URL = URI('http://spidr.rubyforge.org/course/')

  STATIC_DIR = File.expand_path(File.join(File.dirname(__FILE__),'..','static'))

  COURSE_DIR = File.join(STATIC_DIR,'course')

  desc "Build the JSON spec file for the course"
  task :spec do
    File.open(File.join(COURSE_DIR,'specs.json'),'w') do |spec|
      specs = []

      Dir[File.join(COURSE_DIR,'**','*.html')].each do |page|
        doc = Hpricot(open(page))
        page_url = COURSE_URL.merge(page.sub(STATIC_DIR,''))

        link_to_spec = lambda { |container|
          link = container.at('a')

          relative_url = link['href'].to_s
          absolute_url = page_url.merge(URI.encode(relative_url))

          if absolute_url.path
            absolute_url.path = File.expand_path(absolute_url.path)
          end

          {
            :message => link.inner_text,
            :link => relative_url,
            :url => absolute_url,
            :example => link.to_html
          }
        }

        doc.search('.follow[a]') do |follow|
          specs << link_to_spec.call(follow).merge(:behavior => :follow)
        end

        doc.search('.nofollow[a]') do |follow|
          specs << link_to_spec.call(follow).merge(:behavior => :nofollow)
        end

        doc.search('.ignore[a]') do |ignore|
          specs << link_to_spec.call(ignore).merge(:behavior => :ignore)
        end
      end

      spec.write(specs.to_json)
    end
  end
end
