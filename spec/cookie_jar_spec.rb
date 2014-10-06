require 'spidr/cookie_jar'

require 'spec_helper'

describe CookieJar do
  it "should retrieve cookies for the named host" do
    subject['zerosum.org'] = {'admin' => 'ofcourseiam'}

    subject['zerosum.org'].should == {'admin' => 'ofcourseiam'}
  end

  it "should add a cookie to the jar" do
    subject['zerosum.org'] = {'admin' => 'ofcourseiam'}

    subject['zerosum.org'].should == {'admin' => 'ofcourseiam'}
  end

  it "should merge new cookies into the jar" do
    subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
    subject['zerosum.org'] = {'other' => '1'}

    subject['zerosum.org'].should == {
      'admin' => 'ofcourseiam',
      'other' => '1'
    }
  end

  it "should override previous cookies in the jar" do
    subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
    subject['zerosum.org'] = {'admin' => 'somethingcompletelydifferent'}

    subject['zerosum.org'].should == {
      'admin' => 'somethingcompletelydifferent'
    }
  end

  it "should clear all cookies" do
    subject['zerosum.org'] = {'cookie' => 'foobar'}
    subject.clear!

    subject.size.should == 0
  end

  describe "dirty" do
    let(:dirty) { subject.instance_variable_get('@dirty') }

    it "should mark a cookie dirty after adding new params" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'other' => '1'}

      dirty.include?('zerosum.org').should == true
    end

    it "should mark a cookie dirty after overriding params" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'admin' => 'nope'}

      dirty.include?('zerosum.org').should == true
    end

    it "should un-mark a cookie as dirty after re-encoding it" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'admin' => 'nope'}

      dirty.include?('zerosum.org').should == true

      subject.for_host('zerosum.org')

      dirty.include?('zerosum.org').should == false
    end
  end

  describe "cookies_for_host" do
    it "should return an empty Hash for unknown hosts" do
      subject.cookies_for_host('lol.com').should be_empty
    end

    it "should return an empty Hash for hosts with no cookie params" do
      subject['lol.com'] = {}

      subject.cookies_for_host('lol.com').should be_empty
    end

    it "should return cookie parameters for the host" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'other' => '1'}

      cookie = subject.cookies_for_host('zerosum.org')

      cookie['admin'].should == 'ofcourseiam'
      cookie['other'].should == '1'
    end

    it "should include cookies for the parent domain" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['sub.zerosum.org'] = {'other' => '1'}

      cookie = subject.cookies_for_host('sub.zerosum.org')

      cookie['admin'].should == 'ofcourseiam'
      cookie['other'].should == '1'
    end
  end

  describe "for_host" do
    it "should return nil for unknown hosts" do
      subject.for_host('lol.com').should be_nil
    end

    it "should return nil for hosts with no cookie params" do
      subject['lol.com'] = {}

      subject.for_host('lol.com').should be_nil
    end

    it "should encode single cookie params" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}

      subject.for_host('zerosum.org').should == 'admin=ofcourseiam'
    end

    it "should encode multiple cookie params" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'other' => '1'}

      cookie = subject.for_host('zerosum.org')

      cookie.should include('admin=ofcourseiam')
      cookie.should include('; ')
      cookie.should include('other=1')
    end

    it "should include cookies for the parent domain" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['sub.zerosum.org'] = {'other' => '1'}

      cookie = subject.for_host('sub.zerosum.org')

      cookie.should include('admin=ofcourseiam')
      cookie.should include('; ')
      cookie.should include('other=1')
    end

    it 'should include cookie on initialize' do
      subject = Spidr::CookieJar.new('lol.org', {})
      subject.for_host('lol.org').should be_nil
      subject = Spidr::CookieJar.new('zerosum.org', {:tz => 'Europe%2FBerlin'})
      subject.for_host('zerosum.org').should eq('tz=Europe%2FBerlin')
    end
  end
end
