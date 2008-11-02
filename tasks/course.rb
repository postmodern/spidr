require 'hpricot'
require 'json'

namespace :course do
  COURSE_DIR = File.expand_path(File.join(File.dirname(__FILE__),'..','static','course'))

  desc "Build the JSON spec file for the course"
  task :specs do
    File.open(File.join(COURSE_DIR,'specs.json'),'w') do |spec|
      specs = []

      Dir[File.join(COURSE_DIR,'**','*.html')].each do |page|
        doc = Hpricot(open(page))

        link_to_spec = lambda { |container|
          link = container.at('a')

          {
            :message => link.inner_text,
            :link => link['href'],
            :example => link.to_html
          }
        }

        doc.search('.follow[a]') do |follow|
          specs << link_to_spec.call(follow).merge(:behavior => :follow)
        end

        doc.search('.ignore[a]') do |ignore|
          specs << link_to_spec.call(ignore).merge(:behavior => :ignore)
        end
      end

      spec.write(specs.to_json)
    end
  end
end
