# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'hoe/signing'
require './tasks/spec.rb'
require './tasks/yard.rb'
require './tasks/course.rb'
require './lib/spidr/version.rb'

Hoe.spec('spidr') do
  self.rubyforge_name = 'spidr'
  self.developer('Postmodern', 'postmodern.mod3@gmail.com')
  self.remote_rdoc_dir = 'docs'
  self.extra_deps = [
    ['yard', '>=0.2.3.5'],
    ['nokogiri', '>=1.2.0']
  ]
  self.spec_extras = {:has_rdoc => 'yard'}
end

# vim: syntax=Ruby
