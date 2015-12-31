require 'spidr/cookie_jar'

require 'spec_helper'

describe CookieJar do
  it "should retrieve cookies for the named host" do
    subject['zerosum.org'] = {'admin' => 'ofcourseiam'}

    expect(subject['zerosum.org']).to eq({'admin' => 'ofcourseiam'})
  end

  it "should add a cookie to the jar" do
    subject['zerosum.org'] = {'admin' => 'ofcourseiam'}

    expect(subject['zerosum.org']).to eq({'admin' => 'ofcourseiam'})
  end

  it "should merge new cookies into the jar" do
    subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
    subject['zerosum.org'] = {'other' => '1'}

    expect(subject['zerosum.org']).to eq({
      'admin' => 'ofcourseiam',
      'other' => '1'
    })
  end

  it "should override previous cookies in the jar" do
    subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
    subject['zerosum.org'] = {'admin' => 'somethingcompletelydifferent'}

    expect(subject['zerosum.org']).to eq({
      'admin' => 'somethingcompletelydifferent'
    })
  end

  it "should clear all cookies" do
    subject['zerosum.org'] = {'cookie' => 'foobar'}
    subject.clear!

    expect(subject.size).to eq(0)
  end

  describe "dirty" do
    let(:dirty) { subject.instance_variable_get('@dirty') }

    it "should mark a cookie dirty after adding new params" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'other' => '1'}

      expect(dirty.include?('zerosum.org')).to eq(true)
    end

    it "should mark a cookie dirty after overriding params" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'admin' => 'nope'}

      expect(dirty.include?('zerosum.org')).to eq(true)
    end

    it "should un-mark a cookie as dirty after re-encoding it" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'admin' => 'nope'}

      expect(dirty.include?('zerosum.org')).to eq(true)

      subject.for_host('zerosum.org')

      expect(dirty.include?('zerosum.org')).to eq(false)
    end
  end

  describe "cookies_for_host" do
    it "should return an empty Hash for unknown hosts" do
      expect(subject.cookies_for_host('lol.com')).to be_empty
    end

    it "should return an empty Hash for hosts with no cookie params" do
      subject['lol.com'] = {}

      expect(subject.cookies_for_host('lol.com')).to be_empty
    end

    it "should return cookie parameters for the host" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'other' => '1'}

      cookie = subject.cookies_for_host('zerosum.org')

      expect(cookie['admin']).to eq('ofcourseiam')
      expect(cookie['other']).to eq('1')
    end

    it "should include cookies for the parent domain" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['sub.zerosum.org'] = {'other' => '1'}

      cookie = subject.cookies_for_host('sub.zerosum.org')

      expect(cookie['admin']).to eq('ofcourseiam')
      expect(cookie['other']).to eq('1')
    end
  end

  describe "for_host" do
    it "should return nil for unknown hosts" do
      expect(subject.for_host('lol.com')).to be_nil
    end

    it "should return nil for hosts with no cookie params" do
      subject['lol.com'] = {}

      expect(subject.for_host('lol.com')).to be_nil
    end

    it "should encode single cookie params" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}

      expect(subject.for_host('zerosum.org')).to eq('admin=ofcourseiam')
    end

    it "should encode multiple cookie params" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['zerosum.org'] = {'other' => '1'}

      cookie = subject.for_host('zerosum.org')

      expect(cookie).to include('admin=ofcourseiam')
      expect(cookie).to include('; ')
      expect(cookie).to include('other=1')
    end

    it "should include cookies for the parent domain" do
      subject['zerosum.org'] = {'admin' => 'ofcourseiam'}
      subject['sub.zerosum.org'] = {'other' => '1'}

      cookie = subject.for_host('sub.zerosum.org')

      expect(cookie).to include('admin=ofcourseiam')
      expect(cookie).to include('; ')
      expect(cookie).to include('other=1')
    end
  end
end
