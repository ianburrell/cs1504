$: << File.dirname(__FILE__) + "/../lib"

require "test/unit"
require "barcode/ean13plus5"

class TC_EAN13plus5 < Test::Unit::TestCase

    def test_new
        assert(Barcode::EAN13plus5.new("123456789012345678"))
        assert_raise_message(RuntimeError, /EAN-13\+5 must be 18 characters long/) {
            Barcode::EAN13plus5.new("12345678901234567")
        }
        assert_raise_message(RuntimeError, /EAN-13\+5 must be 18 characters long/) {
            Barcode::EAN13plus5.new("1234567890123456789")
        }
    end

    def test_accessors
        bc = Barcode::EAN13plus5.new("123456789012345678")
        assert_equal(bc.code, "123456789012345678")
        assert_equal(bc.ean, "1234567890123")
        assert_equal(bc.type, "EAN-13+5")
        assert_equal(bc.check_digit, "3")
        assert_equal(bc.additional, "45678")
    end

    def test_checksum
        assert_equal(Barcode::EAN13plus5.checksum("978159780044051495"), "0")
        assert_equal(Barcode::EAN13plus5.checksum("978055338268651400"), "6")
    end

    def test_is_valid
        assert(Barcode::EAN13plus5.new("978055338268651400").is_valid)
        assert(Barcode::EAN13plus5.new("978159780044051495").is_valid)
        assert(! Barcode::EAN13plus5.new("978159780044151495").is_valid)
    end
       
    def test_is_isbn
        assert(Barcode::EAN13plus5.new("978159780044051495").is_isbn)
        assert(Barcode::EAN13plus5.new("978055338268651400").is_isbn)
        assert(! Barcode::EAN13plus5.new("232002905114100000").is_isbn)
    end

    def test_to_isbn
        assert_equal(Barcode::EAN13plus5.new("978159780044051495").to_isbn.to_s, "1597800449")
        assert_equal(Barcode::EAN13plus5.new("978055338268651400").to_isbn.to_s, "0553382683")
        assert_raise_message(RuntimeError, /Not bookland/) { 
            Barcode::EAN13plus5.new("232002905114100000").to_isbn
        }
        assert_raise_message(RuntimeError, /Invalid checksum/) {
            Barcode::EAN13plus5.new("978159780044151495").to_isbn
        }
    end

    def assert_raise_message(types, matcher, message = nil, &block)
        args = [types].flatten + [message]
        exception = assert_raise(*args, &block)
        assert_match matcher, exception.message, message
    end

end
