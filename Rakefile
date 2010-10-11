require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:development, :doc)
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'
require './lib/spidr/version.rb'

Jeweler::Tasks.new do |gem|
  gem.name = 'spidr'
  gem.version = Spidr::VERSION
  gem.license = 'MIT'
  gem.summary = %Q{A versatile Ruby web spidering library}
  gem.description = %Q{Spidr is a versatile Ruby web spidering library that can spider a site, multiple domains, certain links or infinitely. Spidr is designed to be fast and easy to use.}
  gem.email = 'postmodern.mod3@gmail.com'
  gem.homepage = 'http://github.com/postmodern/spidr'
  gem.authors = ['Postmodern']
  gem.has_rdoc = 'yard'
end
Jeweler::GemcutterTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
