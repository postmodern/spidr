= Spidr

* http://spidr.rubyforge.org/
* http://github.com/postmodern/spidr/
* Postmodern (postmodern.mod3 at gmail.com)

== DESCRIPTION:

Spidr is a versatile Ruby web spidering library that can spider a site,
multiple domains, certain links or infinitely. Spidr is designed to be fast
and easy to use.

== FEATURES/PROBLEMS:

* Black-list or white-list URLs based upon:
  * Host name
  * Port number
  * Full link
  * URL extension
* Provides call-backs for:
  * Every visited Page.
  * Every visited URL.
  * Every visited URL that matches a specified pattern.
* Custom User-Agent strings.
* Custom proxy settings.

== REQUIREMENTS:

* {nokogiri}[http://nokogiri.rubyforge.org/]

== INSTALL:

  $ sudo gem install spidr

== EXAMPLES:

* Start spidering from a URL:

    Spidr.start_at('http://tenderlovemaking.com/')

* Spider a host:

    Spidr.host('www.0x000000.com')

* Spider a site:

    Spidr.site('http://hackety.org/')

* Print out visited URLs:

    Spidr.site('http://rubyinside.org/') do |spider|
      spider.every_url { |url| puts url }
    end

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
