require 'uri'
require 'strscan'

module URI
  #
  # Expands a URI decoded path, into a proper absolute path.
  #
  # @param [String] path
  #   The path from a URI.
  #
  # @return [String]
  #   The expanded path.
  #
  # @example
  #   URI.expand_path('./path')
  #   # => "path"
  #
  # @example
  #   URI.expand_path('test/../path')
  #   # => "path"
  #
  # @example
  #   URI.exand_path('/test/path/')
  #   # => "/test/path/"
  #
  # @example
  #   URI.expand_path('/test/../path')
  #   # => "/path"
  #
  def self.expand_path(path)
    if path.start_with?('/')
      prefix, path = path[0,1], path[1..-1]
    else
      prefix = ''
    end

    if path.end_with?('/')
      suffix, path = path[-1,1], path[0..-2]
    else
      suffix = ''
    end

    scanner = StringScanner.new(path)
    stack   = []

    until scanner.eos?
      if (dir = scanner.scan(/^[^\/]+/))
        case dir
        when '..' then stack.pop
        when '.'  then false
        else           stack.push(dir)
        end
      else
        scanner.skip(/\/+/)
      end
    end

    unless stack.empty? then "#{prefix}#{stack.join('/')}#{suffix}"
    else                     '/'
    end
  end
end
