source 'https://rubygems.org'

platform :jruby do
  gem 'jruby-openssl'
end

gemspec

gem 'robots', group: :robots

group :development do
  gem 'rake'
  gem 'rubygems-tasks', '~> 0.2'

  gem 'rspec',    '~> 3.0'
  gem 'rexml' # HACK: workaround for https://github.com/jnunemaker/crack/pull/62
  gem 'webmock',  '~> 3.0'
  gem 'sinatra',  '~> 2.0'

  gem 'kramdown'
  gem 'yard',     '~> 0.9'
end
