#!/usr/bin/ruby -w

$: << File.dirname(__FILE__) + "/../lib"

require "test/unit"
require "cs1504"

class TC_Commands < Test::Unit::TestCase

  def test_make_command
    cs1504 = CS1504.new("/dev/ttyS0")
    assert_equal(cs1504.make_command(1), "\x01\x02\x00\x9F\xDE")
    assert_equal(cs1504.make_command(2), "\x02\x02\x00\x9F\x2E")
    assert_equal(cs1504.make_command(3, [ "\002\001", "\004\000" ]), "\003\002\002\002\001\002\004\000\000\275\077")
    assert_equal(cs1504.make_command(4, [ "\001" ]), "\x04\x02\x01\x01\x00\xD7\x7B")
    assert_equal(cs1504.make_command(5), "\x05\x02\x00\x5E\x9F")
    assert_equal(cs1504.make_command(7), "\x07\x02\x00\x9E\x3E")
    assert_equal(cs1504.make_command(10), "\x0A\x02\x00\x5D\xAF")
  end

  def test_interrogate
    cs1504 = CS1504.new("/dev/ttyS0")
    $stderr.print(cs1504.interrogate())
  end

end
