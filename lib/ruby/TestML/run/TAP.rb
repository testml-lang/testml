require 'TestML/run'
require 'TestML/tap'

class TestMLTAP < Run
  attr_accessor :tap

  class << self

    def run file
      self.new.from_file(file).test
    end

  end

  def initialize
    super
    self.tap = TAP.new
  end

  def test_begin
  end


end
