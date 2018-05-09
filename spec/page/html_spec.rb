require 'spec_helper'
require 'example_page'

require 'spidr/page'

describe Page do
  include_context "example Page"

  let(:body) { %{<html><head><title>example</title></head><body><p>hello</p></body></html>} }

  describe "#title" do
    context "when there is a title" do
      it "should return the title inner_text" do
        expect(subject.title).to be == 'example'
      end
    end

    context "when there is no title" do
      let(:body) { %{<html><head></head><body><p>hello</p></body></html>} }

      it "should return nil" do
        expect(subject.title).to be nil
      end
    end
  end

  describe "#each_meta_redirect" do
    context "when the Content-Type is text/html" do
      let(:content_type) { 'text/html' }

      context "and the HTML is valid" do
        let(:link)    { '/link' }
        let(:refresh) { 'refresh' }
        let(:body)    { %{<html><head><meta http-equiv="#{refresh}" content="4; url=#{link}" /></head><body>Redirecting...</body></html>} }

        it "should yield each meta http-equiv='refresh' URL" do
          expect { |b|
            subject.each_meta_redirect(&b)
          }.to yield_successive_args(link)
        end

        context "but when http-equiv is REFRESH" do
          let(:refresh) { 'REFRESH' }

          it "should ignore the case of refresh" do
            expect { |b|
              subject.each_meta_redirect(&b)
            }.to yield_successive_args(link)
          end
        end

        context "but the http-equiv attribute is missing" do
          let(:body) { %{<html><head><meta http-equiv="#{refresh}" content="4; url=#{link}" /><meta content="4; url=#{link}2" /></head><body>Redirecting...</body></html>} }

          it "should ignore those meta tags" do
            expect { |b|
              subject.each_meta_redirect(&b)
            }.to yield_successive_args(link)
          end
        end

        context "but http-equiv is not refresh" do
          let(:body) { %{<html><head><meta http-equiv="#{refresh}" content="4; url=#{link}" /><meta http-equiv="content-type" content="#{content_type}" /></head><body></body></html>} }

          it "should ignore those meta tags" do
            expect { |b|
              subject.each_meta_redirect(&b)
            }.to yield_successive_args(link)
          end
        end

        context "but the content attribute is missing" do
          let(:body) { %{<html><head><meta http-equiv="#{refresh}" content="4; url=#{link}" /><meta http-equiv="#{refresh}" /></head><body>Redirecting...</body></html>} }

          it "should ignore those meta tags" do
            expect { |b|
              subject.each_meta_redirect(&b)
            }.to yield_successive_args(link)
          end
        end

        context "but the content attribute does not contain url=..." do
          let(:body) { %{<html><head><meta http-equiv="#{refresh}" content="4; url=#{link}" /><meta http-equiv="#{refresh}" content="0" /></head><body>Redirecting...</body></html>} }

          it "should ignore those meta tags" do
            expect { |b|
              subject.each_meta_redirect(&b)
            }.to yield_successive_args(link)
          end
        end
      end

      context "but the HTML cannot be parsed" do
        let(:body) { "<html></" }

        it "should yield nothing" do
          expect { |b| subject(&b) }.not_to yield_control
        end
      end
    end

    context "when the Content-Type is not text/html" do
      let(:content_type) { 'text/xml' }

      it "should yield nothing" do
        expect { |b| subject(&b) }.not_to yield_control
      end
    end

    context "when not given a block" do
      it "should return an Enumerator" do
        expect(subject.each_meta_redirect).to be_kind_of(Enumerator)
      end
    end
  end

  describe "#meta_redirect?" do
    context "when there are meta refresh redirects" do
      let(:body)    { %{<html><head><meta http-equiv="refresh" content="4; url=/link" /></head><body>Redirecting...</body></html>} }

      it { expect(subject.meta_redirect?).to be true }
    end

    context "when there are no meta refresh redirects" do
      let(:body)    { %{<html><head><meta http-equiv="content-type" content="text/html" /></head><body>Redirecting...</body></html>} }

      it { expect(subject.meta_redirect?).to be false }
    end
  end

  describe "#meta_redirects" do
    context "when there are meta refresh redirects" do
      let(:link1) { "/link1" }
      let(:link2) { "/link2" }
      let(:body)  { %{<html><head><meta http-equiv="refresh" content="4; url=#{link1}" /><meta http-equiv="refresh" content="1; url=#{link2}" /></head><body>Redirecting...</body></html>} }

      it "should return each meta refresh redirect URL" do
        expect(subject.meta_redirects).to be == [link1, link2]
      end
    end

    context "when there are no meta refresh redirects" do
      let(:body) { %{<html><head><meta http-equiv="content-type" content="text/html" /></head><body>Redirecting...</body></html>} }

      it { expect(subject.meta_redirects).to be == [] }
    end
  end

  describe "#each_redirect" do
    context "when the Location header is set" do
      let(:link)    { "http://#{host}/link" }
      let(:headers) { {'Location' => link}  }

      it "should yield the Location header" do
        expect { |b|
          subject.each_redirect(&b)
        }.to yield_successive_args(link)
      end
    end

    context "when there are multiple Location headers" do
      let(:link1)   { "http://#{host}/link1" }
      let(:link2)   { "http://#{host}/link2" }
      let(:headers) { {'Location' => [link1, link2]} }

      it "should yield each Location header value" do
        expect { |b|
          subject.each_redirect(&b)
        }.to yield_successive_args(link1, link2)
      end
    end

    context "when there is no Location header set" do
      context "but there are meta refresh redirects" do
        let(:link1) { "/link1" }
        let(:link2) { "/link2" }
        let(:body)  { %{<html><head><meta http-equiv="refresh" content="4; url=#{link1}" /><meta http-equiv="refresh" content="1; url=#{link2}" /></head><body>Redirecting...</body></html>} }

        it "should yield each meta refresh redirect URL" do
          expect { |b|
            subject.each_redirect(&b)
          }.to yield_successive_args(link1, link2)
        end
      end

      context "and there are no meta refresh redirects" do
        it do
          expect { |b|
            subject.each_redirect(&b)
          }.not_to yield_control
        end
      end
    end

    context "when not given a block" do
      it "should return an Enumerator" do
        expect(subject.each_redirect).to be_kind_of(Enumerator)
      end
    end
  end

  context "#redirects_to" do
    context "when there are redirects" do
      let(:link1)   { "http://#{host}/link1" }
      let(:link2)   { "http://#{host}/link2" }
      let(:headers) { {'Location' => [link1, link2]} }

      it "should return the redirects as an Array" do
        expect(subject.redirects_to).to be == [link1, link2]
      end
    end

    context "when there are no redirects" do
      it { expect(subject.redirects_to).to be == [] }
    end
  end

  describe "#each_mailto" do
    context "when the Content-Type is text/html" do
      let(:content_type) { 'text/html' }

      context "and the HTML is valid" do
        let(:email1) { "bob@example.com" }
        let(:email2) { "jim@example.com" }
        let(:body)   { %{<html><body><a href="mailto:#{email1}">email1</a> <a href="/link">link</a> <a href="mailto:#{email2}">email2</a></body></html>} }

        it "should yield each a link where the href starts with 'mailto:'" do
          expect { |b|
            subject.each_mailto(&b)
          }.to yield_successive_args(email1, email2)
        end
      end

      context "but the HTML is not valid" do
        let(:body) { "<html" }

        it "should yield nothing" do
          expect { |b|
            subject.each_mailto(&b)
          }.not_to yield_control
        end
      end
    end

    context "when the Content-Type is not text/html" do
      let(:content_type) { 'text/plain' }

      it "should yield nothing" do
        expect { |b|
          subject.each_mailto(&b)
        }.not_to yield_control
      end
    end
  end

  describe "#mailtos" do
    context "when there are 'mailto:' links" do
      let(:email1) { "bob@example.com" }
      let(:email2) { "jim@example.com" }
      let(:body)   { %{<html><body><a href="mailto:#{email1}">email1</a> <a href="/link">link</a> <a href="mailto:#{email2}">email2</a></body></html>} }

      it "should return all 'mailto:' links" do
        expect(subject.mailtos).to be == [email1, email2]
      end
    end

    context "when there are no 'mailto:' links" do
      it { expect(subject.mailtos).to be == [] }
    end
  end

  describe "#each_link" do
    context "when the page contains a links" do
      let(:link1) { '/link1' }
      let(:link2) { '/link2' }
      let(:body)  { %{<html><body><a href="#{link1}">link1</a> <a href="#{link2}">link2</a></body></html>} }

      it "should yield each a/@href value" do
        expect { |b|
          subject.each_link(&b)
        }.to yield_successive_args(link1, link2)
      end
    end

    context "when the page contains frames" do
      let(:frame1) { '/frame1' }
      let(:frame2) { '/frame2' }
      let(:body)   { %{<html><body><frameset><frame src="#{frame1}" /><frame src="#{frame2}" /></frameset></body></html>} }

      it "should yield each frame/@src value" do
        expect { |b|
          subject.each_link(&b)
        }.to yield_successive_args(frame1, frame2)
      end
    end

    context "when the page contains iframes" do
      let(:iframe1) { '/iframe1' }
      let(:iframe2) { '/iframe2' }
      let(:body)   { %{<html><body><iframe src="#{iframe1}" /><iframe src="#{iframe2}" /></body></html>} }

      it "should yield each iframe/@src value" do
        expect { |b|
          subject.each_link(&b)
        }.to yield_successive_args(iframe1, iframe2)
      end
    end

    context "when the page contains remote stylesheets" do
      let(:stylesheet1) { '/stylesheet1.css' }
      let(:stylesheet2) { '/stylesheet2.css' }
      let(:body)   { %{<html><head><link rel="stylesheet" type="text/css" href="#{stylesheet1}" /><link rel="stylesheet" type="text/css" href="#{stylesheet2}" /><body><p>hello</p></body></html>} }

      it "should yield each link/@href value" do
        expect { |b|
          subject.each_link(&b)
        }.to yield_successive_args(stylesheet1, stylesheet2)
      end
    end

    context "when the page contains remote javascript" do
      let(:javascript1) { '/script1.js' }
      let(:javascript2) { '/script2.js' }
      let(:body)   { %{<html><head><script type="text/javascript" src="#{javascript1}"></script><script type="text/javascript" src="#{javascript2}"></script><body><p>hello</p></body></html>} }

      it "should yield each script/@src value" do
        expect { |b|
          subject.each_link(&b)
        }.to yield_successive_args(javascript1, javascript2)
      end
    end

    context "when the page contains remote javascript" do
      let(:image1) { '/image1.js' }
      let(:image2) { '/image2.js' }
      let(:body)   { %{<html><body><img src="#{image1}" /><img src="#{image2}" /></body></html>} }

      it "should yield each img/@src value" do
        expect { |b|
          subject.each_link(&b)
        }.to yield_successive_args(image1, image2)
      end
    end


  end

  describe "#links" do
    context "when the page contains links" do
      let(:link) { '/link' }
      let(:frame) { '/frame' }
      let(:iframe) { '/iframe' }
      let(:img) { '/img' }
      let(:stylesheet) { '/stylesheet.css' }
      let(:javascript) { '/script.js' }
      let(:body) do
        %{<html>} +
          %{<head>} +
            %{<link rel="stylesheet" type="text/css" href="#{stylesheet}" />} +
            %{<script type="text/javascript" src="#{javascript}"></script>} +
          %{</head>} +
          %{<body>} +
            %{<a href="#{link}">link</a>} +
            %{<frameset><frame src="#{frame}" /></frameset>} +
            %{<iframe src="#{iframe}" />} +
            %{<img src="#{img}" />} +
          %{</body>} +
        %{</html>}
      end

      it "should return an Array of links" do
        expect(subject.links).to be == [
          link,
          frame,
          iframe,
          stylesheet,
          javascript,
          img
        ]
      end
    end

    context "when the page does not contain any links" do
      it { expect(subject.links).to be == [] }
    end
  end

  describe "#each_url" do
    context "when the page contains links" do
      let(:link) { '/link' }
      let(:frame) { '/frame' }
      let(:iframe) { '/iframe' }
      let(:img) { '/img' }
      let(:stylesheet) { '/stylesheet.css' }
      let(:javascript) { '/script.js' }
      let(:body) do
        %{<html>} +
          %{<head>} +
            %{<link rel="stylesheet" type="text/css" href="#{stylesheet}" />} +
            %{<script type="text/javascript" src="#{javascript}"></script>} +
          %{</head>} +
          %{<body>} +
            %{<a href="#{link}">link</a>} +
            %{<frameset><frame src="#{frame}" /></frameset>} +
            %{<iframe src="#{iframe}" />} +
            %{<img src="#{img}" />} +
          %{</body>} +
        %{</html>}
      end

      it "should return an Array of absolute URIs" do
        expect { |b| subject.each_url(&b) }.to yield_successive_args(
          URI("http://#{host}#{link}"),
          URI("http://#{host}#{frame}"),
          URI("http://#{host}#{iframe}"),
          URI("http://#{host}#{stylesheet}"),
          URI("http://#{host}#{javascript}"),
          URI("http://#{host}#{img}")
        )
      end
    end

    context "when the page contains no links" do
      it do
        expect { |b|
          subject.each_url(&b)
        }.not_to yield_control
      end
    end
  end

  describe "#urls" do
    context "when the page contains links" do
      let(:link) { '/link' }
      let(:frame) { '/frame' }
      let(:iframe) { '/iframe' }
      let(:img) { '/mg' }
      let(:stylesheet) { '/stylesheet.css' }
      let(:javascript) { '/script.js' }
      let(:body) do
        %{<html>} +
          %{<head>} +
            %{<link rel="stylesheet" type="text/css" href="#{stylesheet}" />} +
            %{<script type="text/javascript" src="#{javascript}"></script>} +
          %{</head>} +
          %{<body>} +
            %{<a href="#{link}">link</a>} +
            %{<frameset><frame src="#{frame}" /></frameset>} +
            %{<iframe src="#{iframe}" />} +
            %{<img src="#{img}" />} +
          %{</body>} +
        %{</html>}
      end

      it "should return an Array of absolute URIs" do
        expect(subject.urls).to be == [
          URI("http://#{host}#{link}"),
          URI("http://#{host}#{frame}"),
          URI("http://#{host}#{iframe}"),
          URI("http://#{host}#{stylesheet}"),
          URI("http://#{host}#{javascript}"),
          URI("http://#{host}#{img}")
        ]
      end
    end

    context "when the page contains no links" do
      it { expect(subject.urls).to be == [] }
    end
  end

  describe "#to_absolute" do
    context "when given an relative path" do
      let(:path) { '/foo/' }
      let(:url)  { URI("http://#{host}#{path}") }

      let(:relative_path) { 'bar' }

      subject { super().to_absolute(relative_path) }

      it "should merge it with the page's URI" do
        expect(subject).to be == URI("http://#{host}#{path}#{relative_path}")
      end

      context "when given a relative path with directory traversal" do
        let(:expanded_path) { '/bar' }
        let(:relative_path) { "../../.././../#{expanded_path}" }

        it "should expand the relative path before merging it" do
          expect(subject).to be == URI("http://#{host}#{expanded_path}")
        end
      end
    end

    context "when given an absolute path" do
      let(:path) { '/foo/' }
      let(:url)  { URI("http://#{host}#{path}") }

      let(:absolute_path) { '/bar/' }

      subject { super().to_absolute(absolute_path) }

      it "should override the page URI's path" do
        expect(subject).to be == URI("http://#{host}#{absolute_path}")
      end

      context "when given an absolute path with directory traversal" do
        let(:expanded_path) { '/bar/' }
        let(:absolute_path) { "/../../.././../#{expanded_path}" }

        it "should expand the absolute path before merging it" do
          expect(subject).to be == URI("http://#{host}#{expanded_path}")
        end
      end
    end

    context "when given a remote link" do
      let(:remote_host) { 'foo.example.com' }
      let(:remote_path) { '/bar' }
      let(:link)        { "http://#{remote_host}#{remote_path}" }

      subject { super().to_absolute(link) }

      it "should override the page's URI" do
        expect(subject).to be == URI(link)
      end

      context "when the remote link contains directory traversal" do
        let(:expanded_path) { '/bar' }
        let(:remote_path)   { "/../.././../../#{expanded_path}" }

        it "should expand the remote link's path" do
          expect(subject).to be == URI("http://#{remote_host}#{expanded_path}")
        end
      end

      context "when the remote link ftp://" do
        let(:remote_path) { "/pub" }
        let(:link)        { "ftp://#{remote_host}#{remote_path}" }

        it "should preserve the leading '/' of the path" do
          expect(subject.path).to be == remote_path
        end
      end
    end
  end
end
