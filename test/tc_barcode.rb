$: << File.dirname(__FILE__) + "/../lib"

require "test/unit"
require "barcode/barcode"

class TC_Barcode < Test::Unit::TestCase

    def test_code
        bc = Barcode::Barcode.new("foo")
        assert_equal(bc.code, "foo")
    end

end
