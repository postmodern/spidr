require 'spec_helper'
require 'example_page'

require 'zlib'
require 'spidr/page'

describe Page do
  include_context 'example Page'
  let(:content_type)  { 'application/xml' }

  let(:body) { %{<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"></urlset>} }
  let(:sitemap_urls_xml) do
    <<-SITEMAP_XML
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
       <url>
          <loc>http://example.com/</loc>
       </url>
       <url>
          <loc>http://example.com/page</loc>
       </url>
    </urlset>
    SITEMAP_XML
  end
  let(:sitemap_index_urls_xml) do
    <<-SITEMAP_XML
    <?xml version="1.0" encoding="UTF-8"?>
    <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
       <sitemap>
          <loc>http://example.com/sitemap1.xml.gz</loc>
       </sitemap>
       <sitemap>
          <loc>http://example.com/sitemap2.xml.gz</loc>
       </sitemap>
    </sitemapindex>
    SITEMAP_XML
  end

  describe '#each_sitemap_link' do
    context 'when the page contains sitemap urls' do
      let(:body) { sitemap_urls_xml }

      it 'should return an Array of links' do
        expect { |b| subject.each_sitemap_link(&b) }.to yield_successive_args(
          "http://#{host}/",
          "http://#{host}/page"
        )
      end
    end

    context 'when the page contains gzipped sitemap urls' do
      let(:content_type)  { 'application/gzip' }
      let(:body) do
        io = StringIO.new.tap(&:binmode)
        Zlib::GzipWriter.new(io, nil, nil).tap do |gz|
          gz.write(sitemap_urls_xml)
          gz.close
        end

        io.string
      end

      it 'should return an Array of links' do
        expect { |b| subject.each_sitemap_link(&b) }.to yield_successive_args(
          "http://#{host}/",
          "http://#{host}/page"
        )
      end
    end

    context 'when the page contains no links' do
      it do
        expect { |b|
          subject.each_sitemap_link(&b)
        }.not_to yield_control
      end
    end
  end

  describe '#sitemap_links' do
    context 'when the page contains links' do
      let(:body) { sitemap_urls_xml }

      it 'should return an Array of links' do
        expect(subject.sitemap_links).to be == [
          "http://#{host}/",
          "http://#{host}/page"
        ]
      end
    end

    context 'when the page contains no links' do
      it { expect(subject.sitemap_links).to be == [] }
    end
  end

  describe '#each_sitemap_index_link' do
    context 'when the page contains sitemap urls' do
      let(:body) { sitemap_index_urls_xml }

      it 'should return an Array of absolute URIs' do
        expect { |b| subject.each_sitemap_index_link(&b) }.to yield_successive_args(
          "http://#{host}/sitemap1.xml.gz",
          "http://#{host}/sitemap2.xml.gz"
        )
      end
    end

    context 'when the page contains no links' do
      it do
        expect { |b|
          subject.each_sitemap_index_link(&b)
        }.not_to yield_control
      end
    end
  end

  describe '#sitemap_index_links' do
    context 'when the page contains links' do
      let(:body) { sitemap_index_urls_xml }

      it 'should return an Array of absolute URIs' do
        expect(subject.sitemap_index_links).to be == [
          "http://#{host}/sitemap1.xml.gz",
          "http://#{host}/sitemap2.xml.gz"
        ]
      end
    end

    context 'when the page contains no links' do
      it { expect(subject.sitemap_index_links).to be == [] }
    end
  end

  describe '#each_sitemap_url' do
    context 'when the page contains sitemap urls' do
      let(:body) { sitemap_urls_xml }

      it 'should return an Array of absolute URIs' do
        expect { |b| subject.each_sitemap_url(&b) }.to yield_successive_args(
          URI("http://#{host}/"),
          URI("http://#{host}/page")
        )
      end
    end

    context 'when the page contains gzipped sitemap urls' do
      let(:content_type)  { 'application/gzip' }
      let(:body) do
        io = StringIO.new.tap(&:binmode)
        Zlib::GzipWriter.new(io, nil, nil).tap do |gz|
          gz.write(sitemap_urls_xml)
          gz.close
        end

        io.string
      end

      it 'should return an Array of absolute URIs' do
        expect { |b| subject.each_sitemap_url(&b) }.to yield_successive_args(
          URI("http://#{host}/"),
          URI("http://#{host}/page")
        )
      end
    end

    context 'when the page contains no links' do
      it do
        expect { |b|
          subject.each_sitemap_url(&b)
        }.not_to yield_control
      end
    end
  end

  describe '#sitemap_urls' do
    context 'when the page contains links' do
      let(:body) { sitemap_urls_xml }

      it 'should return an Array of absolute URIs' do
        expect(subject.sitemap_urls).to be == [
          URI("http://#{host}/"),
          URI("http://#{host}/page")
        ]
      end
    end

    context 'when the page contains no links' do
      it { expect(subject.sitemap_urls).to be == [] }
    end
  end

  describe '#each_sitemap_index_url' do
    context 'when the page contains sitemap urls' do
      let(:body) { sitemap_index_urls_xml }

      it 'should return an Array of absolute URIs' do
        expect { |b| subject.each_sitemap_index_url(&b) }.to yield_successive_args(
          URI("http://#{host}/sitemap1.xml.gz"),
          URI("http://#{host}/sitemap2.xml.gz")
        )
      end
    end

    context 'when the page contains no links' do
      it do
        expect { |b|
          subject.each_sitemap_index_url(&b)
        }.not_to yield_control
      end
    end
  end

  describe '#sitemap_index_urls' do
    context 'when the page contains links' do
      let(:body) { sitemap_index_urls_xml }

      it 'should return an Array of absolute URIs' do
        expect(subject.sitemap_index_urls).to be == [
          URI("http://#{host}/sitemap1.xml.gz"),
          URI("http://#{host}/sitemap2.xml.gz")
        ]
      end
    end

    context 'when the page contains no links' do
      it { expect(subject.sitemap_index_urls).to be == [] }
    end
  end
end
