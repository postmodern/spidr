require 'spec_helper'
require 'example_app'

require 'spidr/agent'

describe Agent do
  describe "sitemap" do
    context "from common sitemap index path" do
      include_context "example App"

      subject { described_class.new(host: host, sitemap: true) }

      app do
        before do
          content_type 'application/xml'
        end

        get '/sitemap-index.xml' do
          <<-SITEMAP_XML
            <?xml version="1.0" encoding="UTF-8"?>
            <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
               <sitemap>
                  <loc>http://example.com/my-sitemap.xml</loc>
               </sitemap>
            </sitemapindex>
          SITEMAP_XML
        end

        get '/my-sitemap.xml' do
          <<-SITEMAP_XML
          <?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <url>
               <loc>http://example.com/</loc>
            </url>
             <url>
                <loc>http://example.com/some-path</loc>
             </url>
          </urlset>
          SITEMAP_XML
        end
      end

      before do
        stub_request(:any, /#{Regexp.escape(host)}/).to_rack(app)
      end

      it 'should fetch all URLs in sitemap' do
        urls = subject.sitemap_urls('http://example.com')
        expected = [
          URI('http://example.com/'),
          URI('http://example.com/some-path')
        ]
        expect(urls).to eq(expected)
      end
    end
  end
end
