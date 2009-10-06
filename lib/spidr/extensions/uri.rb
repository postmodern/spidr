require 'uri'

module URI
  #
  # Normalizes a URI decoded path, into a proper absolute path.
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
