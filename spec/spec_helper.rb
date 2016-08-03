require 'rspec'
require 'webmock/rspec'
require 'spidr/version'

include Spidr

RSpec.configure do |config|
  config.after { WebMock.reset! }
end
