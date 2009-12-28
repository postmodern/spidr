require 'spec_helper'

describe CookieJar do
  before(:each) do
    @cookie_jar = CookieJar.new
  end

  it 'should add a cookie to the jar' do
    @cookie_jar.add('zerosum.org', 'admin=ofcourseiam')
    @cookie_jar.size.should == 1
  end

  it 'should retrieve cookies for the named host' do
    @cookie_jar.add('zerosum.org', 'admin=ofcourseiam')
    @cookie_jar.add('zerosum.org', 'anothercookie=cookievalue')
    @cookie_jar.cookies_for('zerosum.org').should == 'admin=ofcourseiam; anothercookie=cookievalue'
  end

  it 'should clear all cookies' do
    @cookie_jar.add('zerosum.org', 'cookie=foobar')
    @cookie_jar.clear!
    @cookie_jar.size.should == 0
  end

  it "should extract cookie from page headers" do
    raw_cookie_value = '_foo_sess=BAh7DDoOcmV0dXJuX3RvMDo; domain=.foo.com; path=/'

    page = mock('Page', :url => URI.parse('http://zerosum.org/foo/bar.html'), :headers => { 'set-cookie' => [raw_cookie_value] })
    @cookie_jar.from_page(page)

    @cookie_jar.cookies_for('zerosum.org').should == '_foo_sess=BAh7DDoOcmV0dXJuX3RvMDo'
  end
end
