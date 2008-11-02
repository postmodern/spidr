require 'hpricot'
require 'json'

namespace :course do
  DIR_BLACKLIST = ['scripts']

  desc "Build Expected Results files"
  task :build do
    Dir["static/course/*/"].each do |section|
      next if DIR_BLACKLIST.include?(File.basename(section))

      File.open(File.join(section,'results.json'),'w') do |results|
        hash = {:followed => {}, :ignored => {}}

        Dir[File.join(section,'*.html')].each do |page|
          doc = Hpricot(open(page))

          doc.search('.follow[a]') do |follow|
            link = follow.at('a')['href']

            hash[:followed][link] = follow.inner_html
          end

          doc.search('.ignore[a]') do |ignore|
            link = ignore.at('a')['href']

            hash[:ignored][link] = ignore.inner_html
          end
        end

        results.write(hash.to_json)
      end
    end
  end
end
