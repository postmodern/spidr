require 'spidr/cookie_jar'

require 'spec_helper'

describe CookieJar do
  before(:each) do
    @cookie_jar = CookieJar.new
  end

  it "should retrieve cookies for the named host" do
    @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}

    @cookie_jar['zerosum.org'].should == {'admin' => 'ofcourseiam'}
  end

  it "should add a cookie to the jar" do
    @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}

    @cookie_jar['zerosum.org'].should == {'admin' => 'ofcourseiam'}
  end

  it "should merge new cookies into the jar" do
    @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
    @cookie_jar['zerosum.org'] = {'other' => '1'}

    @cookie_jar['zerosum.org'].should == {
      'admin' => 'ofcourseiam',
      'other' => '1'
    }
  end

  it "should override previous cookies in the jar" do
    @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
    @cookie_jar['zerosum.org'] = {'admin' => 'somethingcompletelydifferent'}

    @cookie_jar['zerosum.org'].should == {
      'admin' => 'somethingcompletelydifferent'
    }
  end

  it "should clear all cookies" do
    @cookie_jar['zerosum.org'] = {'cookie' => 'foobar'}
    @cookie_jar.clear!

    @cookie_jar.size.should == 0
  end

  describe "dirty" do
    before(:each) do
      @cookie_jar = CookieJar.new
      @dirty = @cookie_jar.instance_variable_get('@dirty')
    end

    it "should mark a cookie dirty after adding new params" do
      @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
      @cookie_jar['zerosum.org'] = {'other' => '1'}

      @dirty.include?('zerosum.org').should == true
    end

    it "should mark a cookie dirty after overriding params" do
      @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
      @cookie_jar['zerosum.org'] = {'admin' => 'nope'}

      @dirty.include?('zerosum.org').should == true
    end

    it "should un-mark a cookie as dirty after re-encoding it" do
      @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
      @cookie_jar['zerosum.org'] = {'admin' => 'nope'}

      @dirty.include?('zerosum.org').should == true

      @cookie_jar.for_host('zerosum.org')

      @dirty.include?('zerosum.org').should == false
    end
  end

  describe "cookies_for_host" do
    before(:each) do
      @cookie_jar = CookieJar.new
    end

    it "should return an empty Hash for unknown hosts" do
      @cookie_jar.cookies_for_host('lol.com').should be_empty
    end

    it "should return an empty Hash for hosts with no cookie params" do
      @cookie_jar['lol.com'] = {}

      @cookie_jar.cookies_for_host('lol.com').should be_empty
    end

    it "should return cookie parameters for the host" do
      @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
      @cookie_jar['zerosum.org'] = {'other' => '1'}
      cookie = @cookie_jar.cookies_for_host('zerosum.org')

      cookie['admin'].should == 'ofcourseiam'
      cookie['other'].should == '1'
    end

    it "should include cookies for the parent domain" do
      @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
      @cookie_jar['sub.zerosum.org'] = {'other' => '1'}
      cookie = @cookie_jar.cookies_for_host('sub.zerosum.org')

      cookie['admin'].should == 'ofcourseiam'
      cookie['other'].should == '1'
    end
  end

  describe "for_host" do
    before(:each) do
      @cookie_jar = CookieJar.new
    end

    it "should return nil for unknown hosts" do
      @cookie_jar.for_host('lol.com').should be_nil
    end

    it "should return nil for hosts with no cookie params" do
      @cookie_jar['lol.com'] = {}

      @cookie_jar.for_host('lol.com').should be_nil
    end

    it "should encode single cookie params" do
      @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}

      @cookie_jar.for_host('zerosum.org').should == 'admin=ofcourseiam'
    end

    it "should encode multiple cookie params" do
      @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
      @cookie_jar['zerosum.org'] = {'other' => '1'}
      cookie = @cookie_jar.for_host('zerosum.org')

      cookie.should include('admin=ofcourseiam')
      cookie.should include('; ')
      cookie.should include('other=1')
    end

    it "should include cookies for the parent domain" do
      @cookie_jar['zerosum.org'] = {'admin' => 'ofcourseiam'}
      @cookie_jar['sub.zerosum.org'] = {'other' => '1'}
      cookie = @cookie_jar.for_host('sub.zerosum.org')

      cookie.should include('admin=ofcourseiam')
      cookie.should include('; ')
      cookie.should include('other=1')
    end
  end
end
