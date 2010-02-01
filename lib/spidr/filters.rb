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
    # Initializes filtering rules.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [Array] :schemes (['http', 'https'])
    #   The list of acceptable URI schemes to visit.
    #   The `https` scheme will be ignored if `net/https` cannot be loaded.
    #
    # @option options [String] :host
    #   The host-name to visit.
    #
    # @option options [Array<String, Regexp, Proc>] :hosts
    #   The patterns which match the host-names to visit.
    #
    # @option options [Array<String, Regexp, Proc>] :ignore_hosts
    #   The patterns which match the host-names to not visit.
    #
    # @option options [Array<Integer, Regexp, Proc>] :ports
    #   The patterns which match the ports to visit.
    #
    # @option options [Array<Integer, Regexp, Proc>] :ignore_ports
    #   The patterns which match the ports to not visit.
    #
    # @option options [Array<String, Regexp, Proc>] :links
    #   The patterns which match the links to visit.
    #
    # @option options [Array<String, Regexp, Proc>] :ignore_links
    #   The patterns which match the links to not visit.
    #
    # @option options [Array<String, Regexp, Proc>] :exts
    #   The patterns which match the URI path extensions to visit.
    #
    # @option options [Array<String, Regexp, Proc>] :ignore_exts
    #   The patterns which match the URI path extensions to not visit.
    #
    def initialize(options={})
      super(options)

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
    # Sets the list of acceptable URL schemes to visit.
    #
    # @param [Array] new_schemes
    #   The new schemes to visit.
    #
    # @example
    #   agent.schemes = ['http']
    #
    def schemes=(new_schemes)
      @schemes = new_schemes.map { |scheme| scheme.to_s }
    end

    #
    # Specifies the patterns that match host-names to visit.
    #
    # @return [Array<String, Regexp, Proc>]
    #   The host-name patterns to visit.
    #
    def visit_hosts
      @host_rules.accept
    end

    #
    # Adds a given pattern to the visit_hosts.
    #
    # @param [String, Regexp] pattern
    #   The pattern to match host-names with.
    #
    # @yield [host]
    #   If a block is given, it will be used to filter host-names.
    #
    # @yieldparam [String] host
    #   A host-name to accept or reject.
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
    # Specifies the patterns that match host-names to not visit.
    #
    # @return [Array<String, Regexp, Proc>]
    #   The host-name patterns to not visit.
    #
    def ignore_hosts
      @host_rules.reject
    end

    #
    # Adds a given pattern to the ignore_hosts.
    #
    # @param [String, Regexp] pattern
    #   The pattern to match host-names with.
    #
    # @yield [host]
    #   If a block is given, it will be used to filter host-names.
    #
    # @yieldparam [String] host
    #   A host-name to reject or accept.
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
    # Specifies the patterns that match the ports to visit.
    #
    # @return [Array<Integer, Regexp, Proc>]
    #   The port patterns to visit.
    #
    def visit_ports
      @port_rules.accept
    end

    #
    # Adds a given pattern to the visit_ports.
    #
    # @param [Integer, Regexp] pattern
    #   The pattern to match ports with.
    #
    # @yield [port]
    #   If a block is given, it will be used to filter ports.
    #
    # @yieldparam [Integer] port
    #   A port to accept or reject.
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
    # Specifies the patterns that match ports to not visit.
    #
    # @return [Array<Integer, Regexp, Proc>]
    #   The port patterns to not visit.
    #
    def ignore_ports
      @port_rules.reject
    end

    #
    # Adds a given pattern to the ignore_ports.
    #
    # @param [Integer, Regexp] pattern
    #   The pattern to match ports with.
    #
    # @yield [port]
    #   If a block is given, it will be used to filter ports.
    #
    # @yieldparam [Integer] port
    #   A port to reject or accept.
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
    # Specifies the patterns that match the links to visit.
    #
    # @return [Array<String, Regexp, Proc>]
    #   The link patterns to visit.
    #
    def visit_links
      @link_rules.accept
    end

    #
    # Adds a given pattern to the visit_links.
    #
    # @param [String, Regexp] pattern
    #   The pattern to match links with.
    #
    # @yield [link]
    #   If a block is given, it will be used to filter links.
    #
    # @yieldparam [String] link
    #   A link to accept or reject.
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
    # Specifies the patterns that match links to not visit.
    #
    # @return [Array<String, Regexp, Proc>]
    #   The link patterns to not visit.
    #
    def ignore_links
      @link_rules.reject
    end

    #
    # Adds a given pattern to the ignore_links.
    #
    # @param [String, Regexp] pattern
    #   The pattern to match links with.
    #
    # @yield [link]
    #   If a block is given, it will be used to filter links.
    #
    # @yieldparam [String] link
    #   A link to reject or accept.
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
    # Specifies the patterns that match the URI path extensions to visit.
    #
    # @return [Array<String, Regexp, Proc>]
    #   The URI path extensions patterns to visit.
    #
    def visit_exts
      @ext_rules.accept
    end

    #
    # Adds a given pattern to the visit_exts.
    #
    # @param [String, Regexp] pattern
    #   The pattern to match URI path extensions with.
    #
    # @yield [ext]
    #   If a block is given, it will be used to filter URI path extensions.
    #
    # @yieldparam [String] ext
    #   A URI path extension to accept or reject.
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
    # Specifies the patterns that match URI path extensions to not visit.
    #
    # @return [Array<String, Regexp, Proc>]
    #   The URI path extension patterns to not visit.
    #
    def ignore_exts
      @ext_rules.reject
    end

    #
    # Adds a given pattern to the ignore_exts.
    #
    # @param [String, Regexp] pattern
    #   The pattern to match URI path extensions with.
    #
    # @yield [ext]
    #   If a block is given, it will be used to filter URI path extensions.
    #
    # @yieldparam [String] ext
    #   A URI path extension to reject or accept.
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
    # Determines if a given URI scheme should be visited.
    #
    # @param [String] scheme
    #   The URI scheme.
    #
    # @return [Boolean]
    #   Specifies whether the given scheme should be visited.
    #
    def visit_scheme?(scheme)
      if scheme
        return @schemes.include?(scheme)
      else
        return true
      end
    end

    #
    # Determines if a given host-name should be visited.
    #
    # @param [String] host
    #   The host-name.
    #
    # @return [Boolean]
    #   Specifies whether the given host-name should be visited.
    #
    def visit_host?(host)
      @host_rules.accept?(host)
    end

    #
    # Determines if a given port should be visited.
    #
    # @param [Integer] port
    #   The port number.
    #
    # @return [Boolean]
    #   Specifies whether the given port should be visited.
    #
    def visit_port?(port)
      @port_rules.accept?(port)
    end

    #
    # Determines if a given link should be visited.
    #
    # @param [String] link
    #   The link.
    #
    # @return [Boolean]
    #   Specifies whether the given link should be visited.
    #
    def visit_link?(link)
      @link_rules.accept?(link)
    end

    #
    # Determines if a given URI path extension should be visited.
    #
    # @param [String] path
    #   The path that contains the extension.
    #
    # @return [Boolean]
    #   Specifies whether the given URI path extension should be visited.
    #
    def visit_ext?(path)
      @ext_rules.accept?(File.extname(path)[1..-1])
    end
  end
end
