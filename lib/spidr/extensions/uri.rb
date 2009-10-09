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
    dirs = path.gsub(/[\/]{2,}/,'/').scan(/[^\/]*\/|[^\/]+$/)
    new_dirs = []

    dirs.each do |dir|
      if (dir == '..' || dir == '../')
        unless new_dirs == ['/']
          new_dirs.pop
        end
      elsif (dir != '.' && dir != './')
        new_dirs.push(dir)
      end
    end

    return new_dirs.join
  end
end
