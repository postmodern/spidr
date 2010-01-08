# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'hoe/signing'

Hoe.plugin :yard

Hoe.spec('spidr') do
  self.developer('Postmodern', 'postmodern.mod3@gmail.com')

  self.rspec_options += ['--colour', '--format', 'specdoc']

  self.yard_opts = ['--protected']
  self.remote_yard_dir = 'docs'

  self.extra_deps = [
    ['nokogiri', '>=1.2.0']
  ]

  self.extra_dev_deps += [
    ['rspec', '>=1.2.8'],
    ['wsoc', '>=0.1.1']
  ]
end

# vim: syntax=Ruby
