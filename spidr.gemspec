# -*- encoding: utf-8 -*-

begin
  Ore::Specification.new do |gemspec|
    # custom logic here
  end
rescue NameError
  STDERR.puts "The 'spidr.gemspec' file requires Ore."
  STDERR.puts "Run `gem install ore-core` to install Ore."
end
