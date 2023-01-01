# Spidr

[![CI](https://github.com/postmodern/spidr/actions/workflows/ruby.yml/badge.svg)](https://github.com/postmodern/spidr/actions/workflows/ruby.yml)

* [Homepage](https://github.com/postmodern/spidr#readme)
* [Source](https://github.com/postmodern/spidr)
* [Issues](https://github.com/postmodern/spidr/issues)
* [Mailing List](http://groups.google.com/group/spidr)

## Description

Spidr is a versatile Ruby web spidering library that can spider a site,
multiple domains, certain links or infinitely. Spidr is designed to be fast
and easy to use.

## Features

* Follows:
  * `a` tags.
  * `iframe` tags.
  * `frame` tags.
  * Cookie protected links.
  * HTTP 300, 301, 302, 303 and 307 Redirects.
  * Meta-Refresh Redirects.
  * HTTP Basic Auth protected links.
* Black-list or white-list URLs based upon:
  * URL scheme.
  * Host name
  * Port number
  * Full link
  * URL extension
  * Optional `/robots.txt` support.
* Provides callbacks for:
  * Every visited Page.
  * Every visited URL.
  * Every visited URL that matches a specified pattern.
  * Every origin and destination URI of a link.
  * Every URL that failed to be visited.
* Provides action methods to:
  * Pause spidering.
  * Skip processing of pages.
  * Skip processing of links.
* Restore the spidering queue and history from a previous session.
* Custom User-Agent strings.
* Custom proxy settings.
* HTTPS support.

## Examples

Start spidering from a URL:

```ruby
Spidr.start_at('http://tenderlovemaking.com/') do |agent|
  # ...
end
```

Spider a host:

```ruby
Spidr.host('solnic.eu') do |agent|
  # ...
end
```

Spider a domain (and any sub-domains):

```ruby
Spidr.domain('ruby-lang.org') do |agent|
  # ...
end
```

Spider a site:

```ruby
Spidr.site('http://www.rubyflow.com/') do |agent|
  # ...
end
```

Spider multiple hosts:

```ruby
Spidr.start_at('http://company.com/', hosts: ['company.com', /host[\d]+\.company\.com/]) do |agent|
  # ...
end
```

Do not spider certain links:

```ruby
Spidr.site('http://company.com/', ignore_links: [%{^/blog/}]) do |agent|
  # ...
end
```

Do not spider links on certain ports:

```ruby
Spidr.site('http://company.com/', ignore_ports: [8000, 8010, 8080]) do |agent|
  # ...
end
```

Do not spider links blacklisted in robots.txt:

```ruby
Spidr.site('http://company.com/', robots: true) do |agent|
  # ...
end
```

Print out visited URLs:

```ruby
Spidr.site('http://www.rubyinside.com/') do |spider|
  spider.every_url { |url| puts url }
end
```

Build a URL map of a site:

```ruby
url_map = Hash.new { |hash,key| hash[key] = [] }

Spidr.site('http://intranet.com/') do |spider|
  spider.every_link do |origin,dest|
    url_map[dest] << origin
  end
end
```

Print out the URLs that could not be requested:

```ruby
Spidr.site('http://company.com/') do |spider|
  spider.every_failed_url { |url| puts url }
end
```

Finds all pages which have broken links:

```ruby
url_map = Hash.new { |hash,key| hash[key] = [] }

spider = Spidr.site('http://intranet.com/') do |spider|
  spider.every_link do |origin,dest|
    url_map[dest] << origin
  end
end

spider.failures.each do |url|
  puts "Broken link #{url} found in:"

  url_map[url].each { |page| puts "  #{page}" }
end
```

Search HTML and XML pages:

```ruby
Spidr.site('http://company.com/') do |spider|
  spider.every_page do |page|
    puts ">>> #{page.url}"

    page.search('//meta').each do |meta|
      name = (meta.attributes['name'] || meta.attributes['http-equiv'])
      value = meta.attributes['content']

      puts "  #{name} = #{value}"
    end
  end
end
```

Print out the titles from every page:

```ruby
Spidr.site('https://www.ruby-lang.org/') do |spider|
  spider.every_html_page do |page|
    puts page.title
  end
end
```

Print out every HTTP redirect:

```ruby
Spidr.host('company.com') do |spider|
  spider.every_redirect_page do |page|
    puts "#{page.url} -> #{page.headers['Location']}"
  end
end
```

Find what kinds of web servers a host is using, by accessing the headers:

```ruby
servers = Set[]

Spidr.host('company.com') do |spider|
  spider.all_headers do |headers|
    servers << headers['server']
  end
end
```

Pause the spider on a forbidden page:

```ruby
Spidr.host('company.com') do |spider|
  spider.every_forbidden_page do |page|
    spider.pause!
  end
end
```

Skip the processing of a page:

```ruby
Spidr.host('company.com') do |spider|
  spider.every_missing_page do |page|
    spider.skip_page!
  end
end
```

Skip the processing of links:

```ruby
Spidr.host('company.com') do |spider|
  spider.every_url do |url|
    if url.path.split('/').find { |dir| dir.to_i > 1000 }
      spider.skip_link!
    end
  end
end
```

## Requirements

* [ruby] >= 2.0.0
* [nokogiri] ~> 1.3

## Install

```shell
$ gem install spidr
```

## License

Copyright (c) 2008-2016 Hal Brodigan

See {file:LICENSE.txt} for license information.

[ruby]: https://www.ruby-lang.org/
[nokogiri]: http://www.nokogiri.org/
