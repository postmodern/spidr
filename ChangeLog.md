### 0.7.2 / 2025-02-02

* Added the `base64` gem as a dependency to satisfy Bundler.

### 0.7.1 / 2024-01-25

* Switched to using `require_relative` to improve load-times.
* Added `# frozen_string_literal: true` to all files.
* Use keyword arguments for {Spidr.domain}.
* Rescue `URI::Error` instead of `Exception` when calling `URI::HTTP#merge` in
  {Spidr::Page#to_absolute}.

### 0.7.0 / 2022-12-31

* Added {Spidr.domain} and {Spidr::Agent.domain}.
* Added {Spidr::Page#gif?}.
* Added {Spidr::Page#jpeg?}.
* Added {Spidr::Page#icon?} and {Spidr::Page#ico?}.
* Added {Spidr::Page#png?}.
* {Spidr.proxy=} and {Spidr::Agent#proxy=} can now accept a `String` or a
  `URI::HTTP` object.

### 0.6.1 / 2019-10-24

* Check for the opaque component of URIs before attempting to set the path
  component (@kyaroch). This fixes `URI::InvalidURIError: path conflicts with
  opaque` exceptions.
* Fix `@robots` instance variable warning (@spk).

### 0.6.0 / 2016-08-04

* Added {Spidr::Proxy}.
* Added more options to {Spidr::Agent#initialize}:
  * `:default_headers`: specifies the default headers to set in all requests
    (@maccman).
  * `:limit`: specify the maximum number of links to visit.
  * `:open_timeout`, `:read_timeout`, `:ssl_timeout`, `:continue_timeout`,
    and `:keep_alive_timeout`: sets `Net::HTTP` timeouts.
* Allow {Spidr::Settings::Proxy#proxy= Spidr.proxy=} to accept `nil`.
* Use `Net::HTTPResponse#get_fields` in {Spidr::Page} to correctly return
  multiple values for repeated headers.
* Fixed a bug in {Spidr::Page#method_missing} where method names were not being
  correctly converted to header names.
* Fixed a bug in {Spidr::Page#cookie_params} where `Set-Cookie` flags were not
  being filtered out.
* Rewrote the specs to use webmock and increased spec coverage.

### 0.5.0 / 2016-01-03

* Added support for respecting `robots.txt` files.

      Spidr.site('http://reddit.com/', robots: true)

* Added {Spidr.robots=} and {Spidr.robots?}.
* Added {Spidr::Page#each_mailto} and {Spidr::Page#mailtos}.
* Fixed a bug in {Spidr::Agent.host} that limited spidering to only `http://`
  URIs.
* Rescue `Zlib::Error` to catch `Zlib::DataError` and `Zlib::BufError`
  exceptions caused by web servers that use incompatible gzip compression.
* Fixed a bug in {URI.expand_path} where `/../foo` was being expanded to `foo`
  instead of `/foo`.

### 0.4.1 / 2011-12-08

* Catch `OpenSSL::SSL::SSLError` exceptions when initiated HTTPS Sessions.

### 0.4.0 / 2011-08-07

* Added `Spidr::Headers#content_charset`.
* Pass the Page `url` and `content_charset` to Nokogiri in `Spidr::Body#doc`.
  This ensures that Nokogiri will preserve the body encoding.
* Made `Spidr::Headers#is_content_type?` public.
* Allow `Spidr::Headers#is_content_type?` to match the full Content-Type
  or the sub-type.

### 0.3.2 / 2011-06-20

* Added separate intitialize methods for `Spidr::Actions`, `Spidr::Events`,
  `Spidr::Filters` and `Spidr::Sanitizers`.
* Aliased `Spidr::Events#urls_like` to `Spidr::Events#every_url_like`.
* Reduce usage of `self.included` and `module_eval`.
* Reduce usage of nested-blocks.
* Reduce usage of `return`.

### 0.3.1 / 2011-04-22

* Require `set` in `spidr/headers.rb`.

### 0.3.0 / 2011-04-14

* Switched from Jeweler to [Ore](http://github.com/ruby-ore/ore).
* Split all header related methods out of {Spidr::Page} and into
  `Spidr::Headers`.
* Split all body related methods out of {Spidr::Page} and into
  `Spidr::Body`.
* Split all link related methods out of {Spidr::Page} and into
  `Spidr::Links`.
* Added `Spidr::Headers#directory?`.
* Added `Spidr::Headers#json?`.
* Added `Spidr::Links#each_url`.
* Added `Spidr::Links#each_link`.
* Added `Spidr::Links#each_redirect`.
* Added `Spidr::Links#each_meta_redirect`.
* Aliased `Spidr::Headers#raw_cookie` to `Spidr::Headers#cookie`.
* Aliased `Spidr::Body#to_s` to `Spidr::Body#body`.
* Also check for `application/xml` in `Spidr::Headers#xml?`.
* Catch all exceptions when merging URIs in `Spidr::Links#to_absolute`.
* Always prepend a `/` to all FTP URI paths. Fixes a Ruby 1.8 specific
  bug, where it expects an absolute path for all FTP URIs.
* Refactored {URI.expand_path}.
* Start the session in {Spidr::SessionCache#[]} to prevent multiple
  `CONNECT` commands being sent to HTTP Proxies (thanks falaise).

### 0.2.7 / 2010-08-17

* Added {Spidr::CookieJar#cookies_for_host} (thanks zapnap).
* Renamed `Spidr::Page#cookie` to `Spidr::Page#raw_cookie`.
* Rescue `URI::InvalidComponentError` exceptions in
  `Spidr::Page#to_absolute` (thanks zapnap).

### 0.2.6 / 2010-07-05

* Fixed a bug in `Spidr::Page#meta_redirect`, by calling
  `Nokogiri::XML::Element#get_attribute` instead of `attr`.

### 0.2.5 / 2010-07-02

* Added `Spidr::Page#meta_redirect`.
* Added `Spidr::Page#meta_redirect?`.
* Manage development dependencies with Bundler.
* Support following "old-school" meta-refresh redirects (thanks zapnap).
* Allow {Spidr::CookieJar} inherit cookies set by a parent domain.
* Fixed a constant lookup issue in {Spidr::Agent}.
* Use `yield` instead of `block.call` when necessary.

### 0.2.4 / 2010-05-05

* Added `Spidr::Filters#visit_urls`.
* Added `Spidr::Filters#visit_urls_like`.
* Added `Spidr::Filters#ignore_urls`.
* Added `Spidr::Filters#ignore_urls_like`.
* Added `Spidr::Page#is_content_type?`.
* Default `Spidr::Page#body` to an empty String.
* Default `Spidr::Page#content_type` to an empty String.
* Default `Spidr::Page#content_types` to an empty Array.
* Improved reliability of {Spidr::Page#is_redirect?}.
* Improved content type detection in {Spidr::Page} to handle `Content-Type`
  headers containing charsets (thanks Josh Lindsey).

### 0.2.3 / 2010-02-27

* Migrated to Jeweler, for the packaging and releasing RubyGems.
* Switched to MarkDown formatted YARD documentation.
* Added `Spidr::Events#every_link`.
* Added {Spidr::SessionCache#active?}.
* Added specs for {Spidr::SessionCache}.

### 0.2.2 / 2010-01-06

* Require Web Spider Obstacle Course (WSOC) >= 0.1.1.
* Integrated the new WSOC into the specs.
* Removed the built-in Web Spider Obstacle Course.
* Added `Spidr::Page#content_types`.
* Added `Spidr::Page#cookie`.
* Added `Spidr::Page#cookies`.
* Added `Spidr::Page#cookie_params`.
* Added `Spidr::Sanitizers`.
* Added {Spidr::SessionCache}.
* Added {Spidr::CookieJar} (thanks Nick Plante).
* Added {Spidr::AuthStore} (thanks Nick Plante).
* Added {Spidr::Agent#post_page} (thanks Nick Plante).
* Renamed `Spidr::Agent#get_session` to {Spidr::SessionCache#[]}.
* Renamed `Spidr::Agent#kill_session` to {Spidr::SessionCache#kill!}.

### 0.2.1 / 2009-11-25

* Added `Spidr::Events#every_ok_page`.
* Added `Spidr::Events#every_redirect_page`.
* Added `Spidr::Events#every_timedout_page`.
* Added `Spidr::Events#every_bad_request_page`.
* Added `Spidr::Events#every_unauthorized_page`.
* Added `Spidr::Events#every_forbidden_page`.
* Added `Spidr::Events#every_missing_page`.
* Added `Spidr::Events#every_internal_server_error_page`.
* Added `Spidr::Events#every_txt_page`.
* Added `Spidr::Events#every_html_page`.
* Added `Spidr::Events#every_xml_page`.
* Added `Spidr::Events#every_xsl_page`.
* Added `Spidr::Events#every_doc`.
* Added `Spidr::Events#every_html_doc`.
* Added `Spidr::Events#every_xml_doc`.
* Added `Spidr::Events#every_xsl_doc`.
* Added `Spidr::Events#every_rss_doc`.
* Added `Spidr::Events#every_atom_doc`.
* Added `Spidr::Events#every_javascript_page`.
* Added `Spidr::Events#every_css_page`.
* Added `Spidr::Events#every_rss_page`.
* Added `Spidr::Events#every_atom_page`.
* Added `Spidr::Events#every_ms_word_page`.
* Added `Spidr::Events#every_pdf_page`.
* Added `Spidr::Events#every_zip_page`.
* Fixed a bug where {Spidr::Agent#delay} was not being used to delay
  requesting pages.
* Spider `link` and `script` tags in HTML pages (thanks Nick Plante).

### 0.2.0 / 2009-10-10

* Added {URI.expand_path}.
* Added `Spidr::Page#search`.
* Added `Spidr::Page#at`.
* Added `Spidr::Page#title`.
* Added {Spidr::Agent#failures=}.
* Added a HTTP session cache to {Spidr::Agent}, per suggestion of falter.
  * Added `Spidr::Agent#get_session`.
  * Added `Spidr::Agent#kill_session`.
* Added {Spidr::Settings::Proxy#proxy= Spidr.proxy=}.
* Added {Spidr::Settings::Proxy#disable_proxy! Spidr.disable_proxy!}.
* Aliased `Spidr::Page#txt?` to `Spidr::Page#plain_text?`.
* Aliased `Spidr::Page#ok?` to `Spidr::Page#is_ok?`.
* Aliased `Spidr::Page#redirect?` to `Spidr::Page#is_redirect?`.
* Aliased `Spidr::Page#unauthorized?` to `Spidr::Page#is_unauthorized?`.
* Aliased `Spidr::Page#forbidden?` to `Spidr::Page#is_forbidden?`.
* Aliased `Spidr::Page#missing?` to `Spidr::Page#is_missing?`.
* Split URL filtering code out of {Spidr::Agent} and into
  `Spidr::Filters`.
* Split URL / Page event code out of {Spidr::Agent} and into
  `Spidr::Events`.
* Split pause! / continue! / skip_link! / skip_page! methods out of
  {Spidr::Agent} and into `Spidr::Actions`.
* Fixed a bug in `Spidr::Page#code`, where it was not returning an Integer.
* Make sure `Spidr::Page#doc` returns `Nokogiri::XML::Document` objects for
  RSS/RDF/Atom pages as well.
* Fixed the handling of the Location header in `Spidr::Page#links`
  (thanks falter).
* Fixed a bug in `Spidr::Page#to_absolute` where trailing `/` characters on
  URI paths were not being preserved (thanks falter).
* Fixed a bug where the URI query was not being sent with the request
  in {Spidr::Agent#get_page} (thanks Damian Steer).
* Fixed a bug where SSL sessions were not being properly setup
  (thanks falter).
* Switched {Spidr::Agent#history} to be a Set, to improve search-time
  of the history (thanks falter).
* Switched {Spidr::Agent#failures} to a Set.
* Allow a block to be passed to {Spidr::Agent#run}, which will receive all
  pages visited.
* Allow `Spidr::Agent#start_at` and `Spidr::Agent#continue!` to pass blocks
  to {Spidr::Agent#run}.
* Made {Spidr::Agent#visit_page} public.
* Moved to YARD based documentation.

### 0.1.9 / 2009-06-13

* Upgraded to Hoe 2.0.0.
  * Use Hoe.spec instead of Hoe.new.
  * Use the Hoe signing task for signed gems.
* Added the `Spidr::Agent#schemes` and `Spidr::Agent#schemes=` methods.
* Added a warning message if 'net/https' cannot be loaded.
* Allow the list of acceptable URL schemes to be passed into
  {Spidr::Agent#initialize}.
* Allow history and queue information to be passed into
  {Spidr::Agent#initialize}.
* {Spidr::Agent#start_at} no longer clears the history or the queue.
* Fixed a bug in the sanitization of semi-escaped URLs.
* Fixed a bug where https URLs would be followed even if 'net/https'
  could not be loaded.
* Removed Spidr::Agent::SCHEMES.

### 0.1.8 / 2009-05-27

* Added the `Spidr::Agent#pause!` and `Spidr::Agent#continue!` methods.
* Added the `Spidr::Agent#running?` and `Spidr::Agent#paused?` methods.
* Added an alias for pending_urls to the queue methods.
* Added {Spidr::Agent#queue} to provide read access to the queue.
* Added {Spidr::Agent#queue=} and {Spidr::Agent#history=} for setting the
  queue and history.
* Added {Spidr::Agent#to_hash} which returns a Hash of the agents queue and
  history.
* Made {Spidr::Agent#enqueue} and {Spidr::Agent#queued?} public.
* Added more specs.

### 0.1.7 / 2009-04-24

* Added `Spidr::Agent#all_headers`.
* Fixed a bug where {Spidr::Page#headers} was always `nil`.
* {Spidr::Agent} will now follow the Location header in HTTP 300,
  301, 302, 303 and 307 Redirects.
* {Spidr::Agent} will now follow iframe and frame tags.

### 0.1.6 / 2009-04-14

* Added {Spidr::Agent#failures}, a list of URLs which could not be visited.
* Added {Spidr::Agent#failed?}.
* Added `Spidr::Agent#every_failed_url`.
* Added {Spidr::Agent#clear}, which clears the history and failures URL
  lists.
* Improved fault tolerance in {Spidr::Agent#get_page}.
  * If a Network or HTTP error is encountered, the URL will be added to
    the failures list and the next URL will be visited.
* Fixed a typo in `Spidr::Agent#ignore_exts_like`.
* Updated the Web Spider Obstacle Course with links that always fail to be
  visited.

### 0.1.5 / 2009-03-22

* Catch malformed URIs in `Spidr::Page#to_absolute` and return `nil`.
* Filter out `nil` URIs in `Spidr::Page#urls`.

### 0.1.4 / 2009-01-15

* Use Nokogiri for HTML and XML parsing.

### 0.1.3 / 2009-01-10

* Added the `:host` options to {Spidr::Agent#initialize}.
* Added the Web Spider Obstacle Course files to the Manifest.
* Aliased {Spidr::Agent#visited_urls} to {Spidr::Agent#history}.

### 0.1.2 / 2008-11-06

* Fixed a bug in `Spidr::Page#to_absolute` where URLs with no path were not
  receiving a default path of `/`.
* Fixed a bug in `Spidr::Page#to_absolute` where URL paths were not being
  expanded, in order to remove `..` and `.` directories.
* Fixed a bug where absolute URLs could have a blank path, thus causing
  {Spidr::Agent#get_page} to crash when it performed the HTTP request.
* Added RSpec spec tests.
* Created a Web-Spider Obstacle Course
  (http://spidr.rubyforge.org/course/start.html) which is used in the spec
  tests.

### 0.1.1 / 2008-10-04

* Added a reader method for the response instance variable in Page.
* Fixed a bug in {Spidr::Page#method_missing}.

### 0.1.0 / 2008-05-23

* Initial release.
  * Black-list or white-list URLs based upon:
    * Host name
    * Port number
    * Full link
    * URL extension
  * Provides call-backs for:
    * Every visited Page.
    * Every visited URL.
    * Every visited URL that matches a specified pattern.

