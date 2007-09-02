#!/usr/bin/ruby -w

$: << File.dirname(__FILE__) + "/../lib"

require "test/unit"
require "cs1504"

class TC_Device < Test::Unit::TestCase

  def test_interrogate
    cs1504 = CS1504.new("/dev/ttyS0")

    $stderr.print(cs1504.interrogate())
  end

end
