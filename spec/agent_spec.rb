require 'spidr/agent'

require 'spec_helper'
require 'helpers/course'

describe Agent do
  include Helpers::Course

  before(:all) do
    @agent = run_course
  end
end
