# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'hoe/signing'
require './tasks/spec.rb'
require './tasks/yard.rb'

Hoe.spec('spidr') do
  self.developer('Postmodern', 'postmodern.mod3@gmail.com')

  self.readme_file = 'README.rdoc'
  self.history_file = 'History.rdoc'
  self.remote_rdoc_dir = 'docs'

  self.extra_deps = [
    ['nokogiri', '>=1.2.0']
  ]

  self.extra_dev_deps = [
    ['rspec', '>=1.2.8'],
    ['yard', '>=0.4.0'],
    ['wsoc', '>=0.1.1']
  ]

  self.spec_extras = {:has_rdoc => 'yard'}
end

# vim: syntax=Ruby
