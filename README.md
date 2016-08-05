# Spidr

* [Homepage](https://github.com/postmodern/spidr#readme)
* [Source](https://github.com/postmodern/spidr)
* [Issues](https://github.com/postmodern/spidr/issues)
* [Mailing List](http://groups.google.com/group/spidr)
* [IRC](http://webchat.freenode.net/?channels=spidr&uio=d4)
* [![Build Status](https://travis-ci.org/postmodern/spidr.svg)](https://travis-ci.org/postmodern/spidr)

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
* Provides call-backs for:
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

    Spidr.start_at('http://tenderlovemaking.com/')

Spider a host:

    Spidr.host('solnic.eu')

Spider a site:

    Spidr.site('http://www.rubyflow.com/')

Spider multiple hosts:

    Spidr.start_at(
      'http://company.com/',
      hosts: [
        'company.com',
        /host[\d]+\.company\.com/
      ]
    )

Do not spider certain links:

    Spidr.site('http://company.com/', ignore_links: [%{^/blog/}])

Do not spider links on certain ports:

    Spidr.site('http://company.com/', ignore_ports: [8000, 8010, 8080])

Do not spider links blacklisted in robots.txt:

    Spidr.site(
      'http://company.com/',
      robots: true
    )

Print out visited URLs:

    Spidr.site('http://www.rubyinside.com/') do |spider|
      spider.every_url { |url| puts url }
    end

Build a URL map of a site:

    url_map = Hash.new { |hash,key| hash[key] = [] }

    Spidr.site('http://intranet.com/') do |spider|
      spider.every_link do |origin,dest|
        url_map[dest] << origin
      end
    end

Print out the URLs that could not be requested:

    Spidr.site('http://company.com/') do |spider|
      spider.every_failed_url { |url| puts url }
    end

Finds all pages which have broken links:

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

Search HTML and XML pages:

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

Print out the titles from every page:

    Spidr.site('https://www.ruby-lang.org/') do |spider|
      spider.every_html_page do |page|
        puts page.title
      end
    end

Find what kinds of web servers a host is using, by accessing the headers:

    servers = Set[]

    Spidr.host('company.com') do |spider|
      spider.all_headers do |headers|
        servers << headers['server']
      end
    end

Pause the spider on a forbidden page:

    spider = Spidr.host('company.com') do |spider|
      spider.every_forbidden_page do |page|
        spider.pause!
      end
    end

Skip the processing of a page:

    Spidr.host('company.com') do |spider|
      spider.every_missing_page do |page|
        spider.skip_page!
      end
    end

Skip the processing of links:

    Spidr.host('company.com') do |spider|
      spider.every_url do |url|
        if url.path.split('/').find { |dir| dir.to_i > 1000 }
          spider.skip_link!
        end
      end
    end

## Requirements

* [ruby] >= 1.9.1
* [nokogiri] ~> 1.3

## Install

    $ gem install spidr

## License

Copyright (c) 2008-2016 Hal Brodigan

See {file:LICENSE.txt} for license information.

[ruby]: https://www.ruby-lang.org/
[nokogiri]: http://www.nokogiri.org/
