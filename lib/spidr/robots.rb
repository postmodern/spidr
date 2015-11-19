module Spidr
  class Robots
  end

  class NilRobots
    def initialize(_ = nil)
    end

    def allowed?(_)
      true
    end
  end

  class NoRobotsError
    def initialize(_)
      raise("You must install the gem 'robots'")
    end
  end
end

begin
  require 'robots'
  Spidr::Robots = Robots
rescue LoadError => e
  Spidr::Robots = Spidr::NoRobotsError
end
