require 'spec_helper'
require 'example_app'
require 'settings/user_agent_examples'

require 'spidr/agent'

describe Agent do
  it_should_behave_like "includes Spidr::Settings::UserAgent"

  describe ".start_at" do
    module TestAgentStartAt
      class ExampleApp < Sinatra::Base

        set :host, 'example.com'
        set :port, 80

        get '/' do
          '<html><body>should not get here</body></html>'
        end

        get '/entry-point' do
          <<~HTML
          <html>
            <body>
              <a href="/link1">link1</a>
              <a href="http://other.com/offsite-link">offsite link</a>
              <a href="/link2">link2</a>
            </body>
          </html>
          HTML
        end

        get '/link1' do
          '<html><body>got here</body></html>'
        end

        get '/link2' do
          '<html><body>got here</body></html>'
        end
      end

      class OtherApp < Sinatra::Base

        set :host, 'other.com'
        set :port, 80

        get '/offsite-link' do
          '<html><body>should not get here</body></html>'
        end

      end
    end

    subject { described_class }

    let(:host)       { 'example.com' }
    let(:other_host) { 'other.com'   }
    let(:url)        { URI("http://#{host}/entry-point") }

    let(:app)       { TestAgentStartAt::ExampleApp }
    let(:other_app) { TestAgentStartAt::OtherApp   }

    before do
      stub_request(:any, /#{Regexp.escape(host)}/).to_rack(app)
      stub_request(:any, /#{Regexp.escape(other_host)}/).to_rack(other_app)
    end

    it "must spider the website starting at the given URL" do
      agent = subject.start_at(url)

      expect(agent.history).to be == Set[
        URI("http://#{host}/entry-point"),
        URI("http://#{host}/link1"),
        URI("http://#{other_host}/offsite-link"),
        URI("http://#{host}/link2")
      ]
    end
  end

  describe ".site" do
    module TestAgentSite
      class ExampleApp < Sinatra::Base

        set :host, 'example.com'
        set :port, 80

        get '/' do
          '<html><body>should not get here</body></html>'
        end

        get '/entry-point' do
          <<~HTML
            <html>
              <body>
                <a href="/link1">link1</a>
                <a href="http://other.com/offsite-link">offsite link</a>
                <a href="/link2">link2</a>
              </body>
            </html>
          HTML
        end

        get '/link1' do
          '<html><body>got here</body></html>'
        end

        get '/link2' do
          '<html><body>got here</body></html>'
        end

      end
    end

    subject { described_class }

    let(:host) { 'example.com' }
    let(:url)  { URI("http://#{host}/entry-point") }

    let(:app) { TestAgentSite::ExampleApp }

    before do
      stub_request(:any, /#{Regexp.escape(host)}/).to_rack(app)
    end

    it "must spider the website starting at the given URL" do
      agent = subject.site(url)

      expect(agent.history).to be == Set[
        URI("http://#{host}/entry-point"),
        URI("http://#{host}/link1"),
        URI("http://#{host}/link2")
      ]
    end
  end

  describe ".host" do
    module TestAgentHost
      class ExampleApp < Sinatra::Base

        set :host, 'example.com'
        set :port, 80

        get '/' do
          <<~HTML
            <html>
              <body>
                <a href="/link1">link1</a>
                <a href="http://other.com/offsite-link">offsite link</a>
                <a href="/link2">link2</a>
              </body>
            </html>
          HTML
        end

        get '/link1' do
          '<html><body>got here</body></html>'
        end

        get '/link2' do
          '<html><body>got here</body></html>'
        end

      end
    end

    subject { described_class }

    let(:host) { 'example.com' }
    let(:app)  { TestAgentHost::ExampleApp }

    before do
      stub_request(:any, /#{Regexp.escape(host)}/).to_rack(app)
    end

    it "must spider the website starting at the given URL" do
      agent = subject.host(host)

      # XXX: for some reason Set#== was returning false, so convert to an Array
      expect(agent.history.to_a).to be == [
        URI("http://#{host}/"),
        URI("http://#{host}/link1"),
        URI("http://#{host}/link2")
      ]
    end
  end

  describe "#initialize" do
    it "should not be running" do
      expect(subject).to_not be_running
    end

    it "should default :delay to 0" do
      expect(subject.delay).to be 0
    end

    it "should initialize #history" do
      expect(subject.history).to be_empty
    end

    it "should initialize #failures" do
      expect(subject.failures).to be_empty
    end

    it "should initialize #queue" do
      expect(subject.queue).to be_empty
    end

    it "should initialize the #session_cache" do
      expect(subject.sessions).to be_kind_of(SessionCache)
    end

    it "should initialize the #cookie_jar" do
      expect(subject.cookies).to be_kind_of(CookieJar)
    end

    it "should initialize the #auth_store" do
      expect(subject.authorized).to be_kind_of(AuthStore)
    end
  end

  describe "#history=" do
    let(:previous_history) { Set[URI('http://example.com')] }

    before { subject.history = previous_history }

    it "should be able to restore the history" do
      expect(subject.history).to eq(previous_history)
    end

    context "when given an Array of URIs" do
      let(:previous_history)  { [URI('http://example.com')] }
      let(:converted_history) { Set.new(previous_history) }

      it "should convert the Array to a Set" do
        expect(subject.history).to eq(converted_history)
      end
    end

    context "when given an Set of Strings" do
      let(:previous_history)  { Set['http://example.com'] }
      let(:converted_history) do
        previous_history.map { |url| URI(url) }.to_set
      end

      it "should convert the Strings to URIs" do
        expect(subject.history).to eq(converted_history)
      end
    end
  end

  describe "#failures=" do
    let(:previous_failures) { Set[URI('http://example.com')] }

    before { subject.failures = previous_failures }

    it "should be able to restore the failures" do
      expect(subject.failures).to eq(previous_failures)
    end

    context "when given an Array of URIs" do
      let(:previous_failures)  { [URI('http://example.com')] }
      let(:converted_failures) { Set.new(previous_failures) }

      it "should convert the Array to a Set" do
        expect(subject.failures).to eq(converted_failures)
      end
    end

    context "when given an Set of Strings" do
      let(:previous_failures)  { Set['http://example.com'] }
      let(:converted_failures) do
        previous_failures.map { |url| URI(url) }.to_set
      end

      it "should convert the Strings to URIs" do
        expect(subject.failures).to eq(converted_failures)
      end
    end
  end

  describe "#queue=" do
    let(:previous_queue) { [URI('http://example.com')] }

    before { subject.queue = previous_queue }

    it "should be able to restore the queue" do
      expect(subject.queue).to eq(previous_queue)
    end

    context "when given an Set of URIs" do
      let(:previous_queue)  { Set[URI('http://example.com')] }
      let(:converted_queue) { previous_queue.to_a }

      it "should convert the Set to an Array" do
        expect(subject.queue).to eq(converted_queue)
      end
    end

    context "when given an Array of Strings" do
      let(:previous_queue)  { Set['http://example.com'] }
      let(:converted_queue) { previous_queue.map { |url| URI(url) } }

      it "should convert the Strings to URIs" do
        expect(subject.queue).to eq(converted_queue)
      end
    end
  end

  describe "#to_hash" do
    let(:queue)   { [URI("http://example.com/link")] }
    let(:history) { Set[URI("http://example.com/")]  }

    subject do
      described_class.new do |agent|
        agent.queue   = queue
        agent.history = history
      end
    end

    it "should return the queue and history" do
      expect(subject.to_hash).to be == {
        history: history,
        queue:   queue
      }
    end
  end

  context "when spidering" do
    include_context "example App"

    context "local links" do
      context "relative paths" do
        app do
          get '/' do
            %{<html><body><a href="link">relative link</a></body></html>}
          end

          get '/link' do
            '<html><body>got here</body></html>'
          end
        end

        it "should expand relative paths of links" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/link")
          ]
        end

        context "that contain directory escapes" do
          app do
            get '/' do
              %{<html><body><a href="foo/./../../../../link">link</a></body></html>}
            end

            get '/link' do
              '<html><body>got here</body></html>'
            end
          end

          it "should expand relative paths before visiting them" do
            expect(subject.history).to be == Set[
              URI("http://#{host}/"),
              URI("http://#{host}/link")
            ]
          end
        end
      end

      context "absolute paths" do
        app do
          get '/' do
            %{<html><body><a href="/link">absolute path</a></body></html>}
          end

          get '/link' do
            '<html><body>got here</body></html>'
          end
        end

        it "should visit links with absolute paths" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/link")
          ]
        end

        context "that contain directory escapes" do
          app do
            get '/' do
              %{<html><body><a href="/foo/./../../../../link">link</a></body></html>}
            end

            get '/link' do
              '<html><body>got here</body></html>'
            end
          end

          it "should expand absolute links before visiting them" do
            expect(subject.history).to be == Set[
              URI("http://#{host}/"),
              URI("http://#{host}/link")
            ]
          end
        end

      end
    end

    context "remote links" do
      app do
        get '/' do
          %{<html><body><a href="http://#{settings.host}/link">absolute link</a></body></html>}
        end

        get '/link' do
          '<html><body>got here</body></html>'
        end
      end

      it "should visit absolute links" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/link")
        ]
      end

      context "that contain directory escapes" do
        app do
          get '/' do
            %{<html><body><a href="http://#{settings.host}/foo/./../../../../link">link</a></body></html>}
          end

          get '/link' do
            '<html><body>got here</body></html>'
          end
        end

        it "should expand absolute links before visiting them" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/link")
          ]
        end
      end
    end

    context "self-referential links" do
      app do
        get '/' do
          %{<html><body><a href="/">same page</a></body></html>}
        end
      end

      it "should ignore self-referential links" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/")
        ]
      end
    end

    context "circular links" do
      app do
        get '/' do
          %{<html><body><a href="/link">link</a></body></html>}
        end

        get '/link' do
          %{<html><body><a href="/">previous page</a></body></html>}
        end
      end

      it "should ignore links that have been previous visited" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/link")
        ]
      end
    end

    context "link cycles" do
      app do
        get '/' do
          %{<html><body><a href="/link1">first link</a></body></html>}
        end

        get '/link1' do
          %{<html><body><a href="/link2">next link</a></body></html>}
        end

        get '/link2' do
          %{<html><body><a href="/">back to the beginning</a></body></html>}
        end
      end

      it "should ignore links that have been previous visited" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/link1"),
          URI("http://#{host}/link2"),
        ]
      end
    end

    context "fragment links" do
      app do
        get '/' do
          %{<html><body><a href="#fragment">fragment link</a></body></html>}
        end
      end

      it "should ignore fragment links" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/")
        ]
      end
    end

    context "empty links" do
      context "empty href" do
        app do
          get '/' do
            %{<html><body><a href="">empty link</a> <a href=" ">blank link</a> <a>no href</a></body></html>}
          end
        end

        it "should ignore links with empty hrefs" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/")
          ]
        end
      end

      context "whitespace href" do
        app do
          get '/' do
            %{<html><body><a href=" ">blank link</a></body></html>}
          end
        end

        it "should ignore links containing only whitespace" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/")
          ]
        end
      end

      context "missing href" do
        app do
          get '/' do
            %{<html><body><a>no href</a></body></html>}
          end
        end

        it "should ignore links with no href" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/")
          ]
        end
      end
    end

    context "frames" do
      app do
        get '/' do
          <<~HTML
            <html>
              <body>
                <frameset>
                  <frame src="/frame" />
                </frameset>
              </body>
            </html>
          HTML
        end

        get '/frame' do
          %{<html><body><a href="/link">link</a></body></html>}
        end

        get '/link' do
          %{<html><body>got here</body></html>}
        end
      end

      it "should visit the frame and links within the frame" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/frame"),
          URI("http://#{host}/link")
        ]
      end
    end

    context "iframes" do
      app do
        get '/' do
          %{<html><body><iframe src="/iframe" /></body></html>}
        end

        get '/iframe' do
          %{<html><body><a href="/link">link</a></body></html>}
        end

        get '/link' do
          %{<html><body>got here</body></html>}
        end
      end

      it "should visit the iframe and links within the iframe" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/iframe"),
          URI("http://#{host}/link")
        ]
      end
    end

    context "javascript links" do
      app do
        get '/' do
          %{<html><body><a href="javascript:fail();">javascript link</a></body></html>}
        end
      end

      it "should ignore javascript: links" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/")
        ]
      end

      context "when the link has an onclick action" do
        app do
          get '/' do
            %{<html><body><a href="#" onclick="javascript:fail();">onclick link</a></body></html>}
          end
        end

        it "should ignore links with onclick actions" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/")
          ]
        end
      end
    end

    context "cookies" do
      app do
        get '/' do
          response.set_cookie 'visited', 'true'

          %{<html><body><a href="/link">link</a></body></html>}
        end

        get '/link' do
          if request.cookies['visited'] == 'true'
            %{<html><body>got here</body></html>}
          else
            halt 401, "Cookie not set"
          end
        end
      end

      it "should record cookies and send them with each request" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/link"),
        ]

        expect(subject.cookies[host]).to be == {'visited' => 'true'}
      end
    end

    context "redirects" do
      context "300" do
        app do
          get '/' do
            %{<html><body><a href="/redirect">redirect</a></body></html>}
          end

          get '/redirect' do
            redirect to('/link'), 300
          end

          get '/link' do
            %{<html><body>got here</body></html>}
          end
        end

        it "should follow HTTP 300 redirects" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/redirect"),
            URI("http://#{host}/link"),
          ]
        end
      end

      context "301" do
        app do
          get '/' do
            %{<html><body><a href="/redirect">redirect</a></body></html>}
          end

          get '/redirect' do
            redirect to('/link'), 301
          end

          get '/link' do
            %{<html><body>got here</body></html>}
          end
        end

        it "should follow HTTP 301 redirects" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/redirect"),
            URI("http://#{host}/link"),
          ]
        end
      end

      context "302" do
        app do
          get '/' do
            %{<html><body><a href="/redirect">redirect</a></body></html>}
          end

          get '/redirect' do
            redirect to('/link'), 302
          end

          get '/link' do
            %{<html><body>got here</body></html>}
          end
        end

        it "should follow HTTP 302 redirects" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/redirect"),
            URI("http://#{host}/link"),
          ]
        end
      end

      context "303" do
        app do
          get '/' do
            %{<html><body><a href="/redirect">redirect</a></body></html>}
          end

          get '/redirect' do
            redirect to('/link'), 303
          end

          get '/link' do
            %{<html><body>got here</body></html>}
          end
        end

        it "should follow HTTP 303 redirects" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/redirect"),
            URI("http://#{host}/link"),
          ]
        end
      end

      context "307" do
        app do
          get '/' do
            %{<html><body><a href="/redirect">redirect</a></body></html>}
          end

          get '/redirect' do
            redirect to('/link'), 307
          end

          get '/link' do
            %{<html><body>got here</body></html>}
          end
        end

        it "should follow HTTP 307 redirects" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/redirect"),
            URI("http://#{host}/link"),
          ]
        end
      end

      context "meta-refresh" do
        app do
          get '/' do
            %{<html><body><a href="/redirect">redirect</a></body></html>}
          end

          get '/redirect' do
            <<~HTML
              <html>
                <head>
                  <meta http-equiv="refresh" content="0; url=http://#{settings.host}/link" />
                </head>
                <body>Redirecting...</body>
              </html>
            HTML
          end

          get '/link' do
            %{<html><body>got here</body></html>}
          end
        end

        it "should follow meta-refresh redirects" do
          expect(subject.history).to be == Set[
            URI("http://#{host}/"),
            URI("http://#{host}/redirect"),
            URI("http://#{host}/link"),
          ]
        end
      end
    end

    context "Basic-Auth" do
      app do
        set :user,     'admin'
        set :password, 'swordfish'

        get '/' do
          %{<html><body><a href="/private">private link</a></body></html>}
        end

        get '/private' do
          auth =  Rack::Auth::Basic::Request.new(request.env)

          if auth.provided? && auth.basic? && auth.credentials && \
             auth.credentials == [settings.user, settings.password]
            %{<html><body>got here</body></html>}
          else
            headers['WWW-Authenticate'] = %{Basic realm="Restricted Area"}
            halt 401, "<html><body><h1>Not authorized</h1></body></html>"
          end
        end
      end

      before do
        subject.authorized.add("http://#{host}/private", app.user, app.password)
      end

      it "should send HTTP Basic-Auth credentials for protected URLs" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/private")
        ]
      end
    end
  end

  context "when :host is specified" do
    include_context "example App"

    subject { described_class.new(host: host) }

    app do
      get '/' do
        <<~HTML
          <html>
            <body>
              <a href="http://google.com/">external link</a>
              <a href="/link">local link</a>
            </body>
          </html>
        HTML
      end

      get '/link' do
        %{<html><body>got here</body></html>}
      end
    end

    it "should only visit links on the host" do
      expect(subject.history).to be == Set[
        URI("http://#{host}/"),
        URI("http://#{host}/link")
      ]
    end
  end

  context "when :limit is set" do
    include_context "example App"

    let(:limit) { 10 }

    subject { described_class.new(host: host, limit: limit) }

    app do
      get '/' do
        i = Integer(params['i'] || 0)

        %{<html><body><a href="/?i=#{i+1}">next link</a></body></html>}
      end
    end

    it "must only visit the maximum number of links" do
      expect(subject.history).to be == Set[
        URI("http://#{host}/"),
        URI("http://#{host}/?i=1"),
        URI("http://#{host}/?i=2"),
        URI("http://#{host}/?i=3"),
        URI("http://#{host}/?i=4"),
        URI("http://#{host}/?i=5"),
        URI("http://#{host}/?i=6"),
        URI("http://#{host}/?i=7"),
        URI("http://#{host}/?i=8"),
        URI("http://#{host}/?i=9"),
      ]
    end
  end

  context "when :depth is set" do
    include_context "example App"

    app do
      get '/' do
        <<~HTML
          <html>
            <body>
              <a href="/left?d=1">left</a>
              <a href="/right?d=1">right</a>
            </body>
          </html>
        HTML
      end

      get %r{/left|/right} do
        d = Integer(params['d'])

        <<~HTML
          <html>
            <body>
              <a href="/left?d=#{d+1}">left</a>
              <a href="/right?d=#{d+1}">right</a>
            </body>
          </html>
        HTML
      end
    end

    context "depth 0" do
      subject { described_class.new(host: host, max_depth: 0) }

      it "must only visit the first page" do
        expect(subject.history).to be == Set[URI("http://#{host}/")]
      end
    end

    context "depth > 0" do
      subject { described_class.new(host: host, max_depth: 2) }

      it "must visit links below the maximum depth" do
        expect(subject.history).to be == Set[
          URI("http://#{host}/"),
          URI("http://#{host}/left?d=1"),
          URI("http://#{host}/right?d=1"),
          URI("http://#{host}/left?d=2"),
          URI("http://#{host}/right?d=2")
        ]
      end
    end
  end

  context "when :robots is enabled" do
    include_context "example App"

    let(:user_agent) { 'Ruby' }

    subject do
      described_class.new(
        host: host,
        user_agent: user_agent,
        robots: true
      )
    end

    app do
      get '/' do
        <<~HTML
          <html>
            <body>
              <a href="/secret">don't follow this link</a>
              <a href="/pub">follow this link</a>
            </body>
          </html>
        HTML
      end

      get '/pub' do
        %{<html><body>got here</body></html>}
      end

      get '/robots.txt' do
        content_type 'text/plain'

        [
          "User-agent: *",
          'Disallow: /secret',
        ].join($/)
      end
    end

    it "should not follow links Disallowed by robots.txt" do
      expect(subject.history).to be == Set[
        URI("http://#{host}/"),
        URI("http://#{host}/pub")
      ]
    end
  end
end
