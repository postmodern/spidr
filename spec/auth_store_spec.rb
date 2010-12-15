require 'spidr/auth_store'

require 'spec_helper'

describe AuthStore do
  let(:root_uri) { URI('http://zerosum.org/') }
  let(:uri) { root_uri.merge('/course/auth') }

  before(:each) do
    @auth_store = AuthStore.new
    @auth_store.add(uri, 'admin', 'password')
  end

  after(:each) do
    @auth_store.clear!
  end

  it 'should retrieve auth credentials for the URL' do
    @auth_store[root_uri] = AuthCredential.new('user1', 'pass1')
    @auth_store[root_uri].username.should == 'user1'
    @auth_store[root_uri].password.should == 'pass1'
  end 

  it 'should add auth credentials for the URL' do
    lambda {
      @auth_store.add(root_uri, 'user1', 'pass1')
    }.should change(@auth_store, :size)

    @auth_store[root_uri].username.should == 'user1'
    @auth_store[root_uri].password.should == 'pass1'
  end

  describe 'matching' do
    let(:sub_uri) { uri.merge('/course/auth/protected.html') }

    it 'should match a longer URL to the base' do
      @auth_store[sub_uri].username.should == 'admin'
      @auth_store[sub_uri].password.should == 'password'
    end

    it 'should match the longest of all matching URLs' do
      @auth_store.add(uri.merge('/course'), 'user1', 'pass1')
      @auth_store.add(uri.merge('/course/auth/special'), 'user2', 'pass2')
      @auth_store.add(uri.merge('/course/auth/special/extra'), 'user3', 'pass3')

      auth = @auth_store[uri.merge('/course/auth/special/1.html')]
      auth.username.should == 'user2'
      auth.password.should == 'pass2'
    end

    it 'should not match a URL with a different host' do
      remote_uri = URI('http://spidr.rubyforge.org/course/auth')

      @auth_store[remote_uri].should be_nil
    end

    it 'should not match a URL with an alternate path' do
      relative_uri = uri.merge('/course/admin/protected.html')

      @auth_store[relative_uri].should be_nil
    end
  end

  it 'should override previous auth credentials' do
    @auth_store.add(uri, 'newuser', 'newpass')

    @auth_store[uri].username.should == 'newuser'
    @auth_store[uri].password.should == 'newpass'
  end

  it 'should clear all cookies' do
    @auth_store.clear!
    @auth_store.size.should == 0
  end

  describe 'for_url' do
    it 'should return nil if no authorization exists' do
      @auth_store.for_url(URI('http://php.net')).should be_nil
    end

    it 'should create an encoded authorization string' do
      @auth_store.for_url(uri).should == "YWRtaW46cGFzc3dvcmQ=\n"
    end
  end
end
