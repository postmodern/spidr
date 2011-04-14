require 'uri'

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
  def URI.expand_path(path)
    dirs = path.split(/\/+/)

    # append any tailing '/' chars, lost due to String#split
    dirs << '' if path[-1,1] == '/'

    new_dirs = []

    dirs.each do |dir|
      if dir == '..'
        new_dirs.pop
      elsif dir != '.'
        new_dirs.push(dir)
      end
    end

    full_path = new_dirs.join('/')

    # default empty paths to '/'
    full_path = '/' if full_path.empty?

    return full_path
  end
end
