require 'spidr/rules'

module Spidr
  module Filters
    def self.included(base)
      base.module_eval do
        # List of acceptable URL schemes to follow
        attr_reader :schemes
      end
    end

    #
    # Initializes filtering rules with the given _options_.
    #
    # _options_ may contain the following keys:
    # <tt>:schemes</tt>:: The list of acceptable URL schemes to follow.
    #                     Defaults to +http+ and +https+. +https+ URL
    #                     schemes will be ignored if <tt>net/http</tt>
    #                     cannot be loaded.
    # <tt>:host</tt>:: The host-name to visit.
    # <tt>:hosts</tt>:: An +Array+ of host patterns to visit.
    # <tt>:ignore_hosts</tt>:: An +Array+ of host patterns to not visit.
    # <tt>:ports</tt>:: An +Array+ of port patterns to visit.
    # <tt>:ignore_ports</tt>:: An +Array+ of port patterns to not visit.
    # <tt>:links</tt>:: An +Array+ of link patterns to visit.
    # <tt>:ignore_links</tt>:: An +Array+ of link patterns to not visit.
    # <tt>:exts</tt>:: An +Array+ of File extension patterns to visit.
    # <tt>:ignore_exts</tt>:: An +Array+ of File extension patterns to not
    #                         visit.
    #
    def initialize(options={},&block)
      @schemes = []

      if options[:schemes]
        @schemes += options[:schemes]
      else
        @schemes << 'http'

        begin
          require 'net/https'

          @schemes << 'https'
        rescue Gem::LoadError => e
          raise(e)
        rescue ::LoadError
          STDERR.puts "Warning: cannot load 'net/https', https support disabled"
        end
      end

      @host_rules = Rules.new(
        :accept => options[:hosts],
        :reject => options[:ignore_hosts]
      )
      @port_rules = Rules.new(
        :accept => options[:ports],
        :reject => options[:ignore_ports]
      )
      @link_rules = Rules.new(
        :accept => options[:links],
        :reject => options[:ignore_links]
      )
      @ext_rules = Rules.new(
        :accept => options[:exts],
        :reject => options[:ignore_exts]
      )

      if options[:host]
        visit_hosts_like(options[:host])
      end

      if options[:queue]
        self.queue = options[:queue]
      end

      if options[:history]
        self.history = options[:history]
      end
    end

    #
    # Sets the list of acceptable URL schemes to follow to the
    # _new_schemes_.
    #
    # @example
    #   agent.schemes = ['http']
    #
    def schemes=(new_schemes)
      @schemes = new_schemes.map { |scheme| scheme.to_s }
    end

    #
    # Returns the +Array+ of host patterns to visit.
    #
    def visit_hosts
      @host_rules.accept
    end

    #
    # Adds the given _pattern_ to the visit_hosts. If a _block_ is given,
    # it will be added to the visit_hosts.
    #
    def visit_hosts_like(pattern=nil,&block)
      if pattern
        visit_hosts << pattern
      elsif block
        visit_hosts << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL host patterns to not visit.
    #
    def ignore_hosts
      @host_rules.reject
    end

    #
    # Adds the given _pattern_ to the ignore_hosts. If a _block_ is given,
    # it will be added to the ignore_hosts.
    #
    def ignore_hosts_like(pattern=nil,&block)
      if pattern
        ignore_hosts << pattern
      elsif block
        ignore_hosts << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL port patterns to visit.
    #
    def visit_ports
      @port_rules.accept
    end

    #
    # Adds the given _pattern_ to the visit_ports. If a _block_ is given,
    # it will be added to the visit_ports.
    #
    def visit_ports_like(pattern=nil,&block)
      if pattern
        visit_ports << pattern
      elsif block
        visit_ports << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL port patterns to not visit.
    #
    def ignore_ports
      @port_rules.reject
    end

    #
    # Adds the given _pattern_ to the ignore_hosts. If a _block_ is given,
    # it will be added to the ignore_hosts.
    #
    def ignore_ports_like(pattern=nil,&block)
      if pattern
        ignore_ports << pattern
      elsif block
        ignore_ports << block
      end

      return self
    end

    #
    # Returns the +Array+ of link patterns to visit.
    #
    def visit_links
      @link_rules.accept
    end

    #
    # Adds the given _pattern_ to the visit_links. If a _block_ is given,
    # it will be added to the visit_links.
    #
    def visit_links_like(pattern=nil,&block)
      if pattern
        visit_links << pattern
      elsif block
        visit_links << block
      end

      return self
    end

    #
    # Returns the +Array+ of link patterns to not visit.
    #
    def ignore_links
      @link_rules.reject
    end

    #
    # Adds the given _pattern_ to the ignore_links. If a _block_ is given,
    # it will be added to the ignore_links.
    #
    def ignore_links_like(pattern=nil,&block)
      if pattern
        ignore_links << pattern
      elsif block
        ignore_links << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL extension patterns to visit.
    #
    def visit_exts
      @ext_rules.accept
    end

    #
    # Adds the given _pattern_ to the visit_exts. If a _block_ is given,
    # it will be added to the visit_exts.
    #
    def visit_exts_like(pattern=nil,&block)
      if pattern
        visit_exts << pattern
      elsif block
        visit_exts << block
      end

      return self
    end

    #
    # Returns the +Array+ of URL extension patterns to not visit.
    #
    def ignore_exts
      @ext_rules.reject
    end

    #
    # Adds the given _pattern_ to the ignore_exts. If a _block_ is given,
    # it will be added to the ignore_exts.
    #
    def ignore_exts_like(pattern=nil,&block)
      if pattern
        ignore_exts << pattern
      elsif block
        ignore_exts << block
      end

      return self
    end

    protected

    #
    # Returns +true+ if the specified _scheme_ should be visited, returns
    # +false+ otherwise.
    #
    def visit_scheme?(scheme)
      if scheme
        return @schemes.include?(scheme)
      else
        return true
      end
    end

    #
    # Returns +true+ if the specified _host_ should be visited returns
    # +false+ otherwise.
    #
    def visit_host?(host)
      @host_rules.accept?(host)
    end

    #
    # Returns +true+ if the specified _port_ should be visited, returns
    # +false+ otherwise.
    #
    def visit_port?(port)
      @port_rules.accept?(port)
    end

    #
    # Returns +true+ if the specified _link_ should be visited, returns
    # +false+ otherwise.
    #
    def visit_link?(link)
      @link_rules.accept?(link)
    end

    #
    # Returns +true+ if the specified _path_ should be visited, based on
    # the file extension of the _path_, returns +false+ otherwise.
    #
    def visit_ext?(path)
      @ext_rules.accept?(File.extname(path)[1..-1])
    end
  end
end
