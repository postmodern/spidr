require 'spidr/page'

require 'spec_helper'

shared_examples_for "Page" do
  it "should have a status code" do
    expect(@page.code).to be_integer
  end

  it "should have a body" do
    expect(@page.body).not_to be_empty
  end

  it "should provide transparent access to the response headers" do
    expect(@page.content_type).to eq(@page.response['Content-Type'])
  end

  it "should allow content-types" do
    expect(@page.content_types).not_to be_empty
  end
end
