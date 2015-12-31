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
    expect(@auth_store[root_uri].username).to eq('user1')
    expect(@auth_store[root_uri].password).to eq('pass1')
  end 

  it 'should add auth credentials for the URL' do
    expect {
      @auth_store.add(root_uri, 'user1', 'pass1')
    }.to change(@auth_store, :size)

    expect(@auth_store[root_uri].username).to eq('user1')
    expect(@auth_store[root_uri].password).to eq('pass1')
  end

  describe 'matching' do
    let(:sub_uri) { uri.merge('/course/auth/protected.html') }

    it 'should match a longer URL to the base' do
      expect(@auth_store[sub_uri].username).to eq('admin')
      expect(@auth_store[sub_uri].password).to eq('password')
    end

    it 'should match the longest of all matching URLs' do
      @auth_store.add(uri.merge('/course'), 'user1', 'pass1')
      @auth_store.add(uri.merge('/course/auth/special'), 'user2', 'pass2')
      @auth_store.add(uri.merge('/course/auth/special/extra'), 'user3', 'pass3')

      auth = @auth_store[uri.merge('/course/auth/special/1.html')]
      expect(auth.username).to eq('user2')
      expect(auth.password).to eq('pass2')
    end

    it 'should not match a URL with a different host' do
      remote_uri = URI('http://spidr.rubyforge.org/course/auth')

      expect(@auth_store[remote_uri]).to be_nil
    end

    it 'should not match a URL with an alternate path' do
      relative_uri = uri.merge('/course/admin/protected.html')

      expect(@auth_store[relative_uri]).to be_nil
    end
  end

  it 'should override previous auth credentials' do
    @auth_store.add(uri, 'newuser', 'newpass')

    expect(@auth_store[uri].username).to eq('newuser')
    expect(@auth_store[uri].password).to eq('newpass')
  end

  it 'should clear all cookies' do
    @auth_store.clear!
    expect(@auth_store.size).to eq(0)
  end

  describe 'for_url' do
    it 'should return nil if no authorization exists' do
      expect(@auth_store.for_url(URI('http://php.net'))).to be_nil
    end

    it 'should create an encoded authorization string' do
      expect(@auth_store.for_url(uri)).to eq("YWRtaW46cGFzc3dvcmQ=\n")
    end
  end
end
