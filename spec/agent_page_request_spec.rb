require 'spidr/agent'

require 'spec_helper'
require 'fakeweb'
require 'net/http'

describe Agent do

  before(:all) { FakeWeb.allow_net_connect = false }
  after(:all)  { FakeWeb.allow_net_connect = true }

  before(:each) do
    @agent = Agent.new
  end

  describe 'page request handlers' do

    before(:each) do
      @url = URI('http://example.com/course/login')
      @login_body = File.read(File.join(File.dirname(__FILE__), '..', 'static', 'course', 'login.html'))
    end

    it 'should GET the page' do
      FakeWeb.register_uri(:get, @url.to_s, :body => @login_body)
      page = @agent.get_page(@url)
      page.url.should == @url
      page.body.should == @login_body
    end

    describe 'when handling a POST' do
      before(:each) do
        redirect_response = Net::HTTPResponse.new('1.1', '302', 'Found')
        redirect_response['Location'] = 'http://example.com/course/protected'
        redirect_response['Set-Cookie'] = 'loggedinas=admin; expires=Mon, 12-Dec-09 23:06:12; path=/'

        FakeWeb.register_uri(:post, @url.to_s, :response => redirect_response)
      end

      it 'should POST to the page' do
        page = @agent.post_page(@url, { :username => 'admin', :password => 'password' })
        page.body.should == nil
        page.location.should == 'http://example.com/course/protected'
      end

      it 'should capture cookies set in POST response' do
        page = @agent.post_page(@url, { :username => 'admin', :password => 'password' })

        @agent.cookies.size.should == 1
        @agent.cookies.cookies_for('example.com').should == 'loggedinas=admin'
      end

      it 'should use cached cookies in subsequent requests' do
        FakeWeb.register_uri(:get, 'http://example.com/course/start.html', :body => @login_body)

        @agent.post_page(@url, { :username => 'admin', :password => 'password' })

        @agent.cookies.should_receive(:cookies_for).with('example.com').and_return('loggedinas=admin')
        @agent.get_page('http://example.com/course/start.html')
      end
    end

  end
end
