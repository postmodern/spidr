= Spidr

* http://spidr.rubyforge.org/
* http://github.com/postmodern/spidr/
* Postmodern (postmodern.mod3 at gmail.com)

== DESCRIPTION:

Spidr is a versatile Ruby web spidering library that can spider a site,
multiple domains, certain links or infinitely. Spidr is designed to be fast
and easy to use.

== FEATURES:

* Follows:
  * a tags.
  * iframe tags.
  * frame tags.
  * HTTP 300, 301, 302, 303 and 307 Redirects.
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
  * Every URL that failed to be visited.
* Provides action methods to:
  * Pause spidering.
  * Skip processing of links.
  * Skip processing of pages.
* Restore the spidering queue and history from a previous session.
* Custom User-Agent strings.
* Custom proxy settings.

== EXAMPLES:

* Start spidering from a URL:

    Spidr.start_at('http://tenderlovemaking.com/')

* Spider a host:

    Spidr.host('coderrr.wordpress.com')

* Spider a site:

    Spidr.site('http://rubyflow.com/')

* Spider multiple hosts:

    Spidr.start_at(
      'http://company.com/',
      :hosts => [
        'company.com',
	/host\d\.company\.com/
      ]
    )

* Do not spider certain links:

    Spidr.site('http://matasano.com/', :ignore_links => [/log/])

* Print out visited URLs:

    Spidr.site('http://rubyinside.org/') do |spider|
      spider.every_url { |url| puts url }
    end

* Search HTML and XML pages:

    Spidr.site('http://company.withablog.com/') do |spider|
      spider.every_page do |page|
        puts "[-] #{page.url}"

        page.search('//meta').each do |meta|
	  name = (meta.attributes['name'] || meta.attributes['http-equiv'])
	  value = meta.attributes['content']

	  puts "    #{name} = #{value}"
	end
      end
    end

* Print out the titles from every page:

    Spidr.site('http://www.rubypulse.com/') do |spider|
      spider.every_page do |page|
        puts page.title if page.html?
      end
    end

* Find what kinds of web servers a host is using:

    servers = Set[]

    Spidr.host('generic.company.com') do |spider|
      spider.all_headers do |headers|
        servers << headers['server']
      end
    end

* Pause the spider on a forbidden page:

    spider = Spidr.host('overnight.startup.com') do |spider|
      spider.every_page do |page|
        spider.pause! if page.forbidden?
      end
    end

* Skip the processing of a page:

    Spidr.host('sketchy.content.com') do |spider|
      spider.every_page do |page|
        spider.skip_page! if page.not_found?
      end
    end

* Skip the processing of links:

    Spidr.host('sketchy.content.com') do |spider|
      spider.every_url do |url|
        if url.path.split('/').find { |dir| dir.to_i > 1000 }
	  spider.skip_link!
	end
      end
    end

== REQUIREMENTS:

* {nokogiri}[http://nokogiri.rubyforge.org/] >= 1.2.0

== INSTALL:

  $ sudo gem install spidr

== LICENSE:

The MIT License

Copyright (c) 2008-2009 Hal Brodigan

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
