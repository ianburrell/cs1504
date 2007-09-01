$: << File.dirname(__FILE__) + "/../lib"

require "test/unit"
require "barcode/ean13"

class TC_EAN13 < Test::Unit::TestCase

    def test_new
        bc = Barcode::EAN13.new("1234567890123")
        assert_equal(bc.code, "1234567890123")
        assert_raise_message(RuntimeError, /EAN-13 must be 13 characters long/) {
            Barcode::EAN13.new("123456789012")
        }
        assert_raise_message(RuntimeError, /EAN-13 must be 13 characters long/) {
            Barcode::EAN13.new("12345678901234")
        }
    end

    def test_type
        bc = Barcode::EAN13.new("1234567890123")
        assert_equal(bc.type, "EAN-13")
    end

    def test_check_digit
        bc = Barcode::EAN13.new("1234567890123")
        assert_equal(bc.check_digit, "3")
    end

    def test_checksum
        assert_equal(Barcode::EAN13.checksum("978159780044"), "0")
        assert_equal(Barcode::EAN13.checksum("978055338268"), "6")
    end

    def test_is_valid
        assert(Barcode::EAN13.new("9781597800440").is_valid)
        assert(! Barcode::EAN13.new("9781597800441").is_valid)
    end
       
    def test_new_with_check
        assert_equal(Barcode::EAN13.new_with_check("978159780044").to_s, "9781597800440")
        assert_equal(Barcode::EAN13.new_with_check("978055338268").to_s, "9780553382686")
    end
 
    def test_is_isbn
        assert(Barcode::EAN13.new("9781597800440").is_isbn)
        assert(Barcode::EAN13.new("9780553382686").is_isbn)
        assert(! Barcode::EAN13.new("2320029051141").is_isbn)
    end

    def test_to_isbn
        assert_equal(Barcode::EAN13.new("9781597800440").to_isbn.to_s, "1597800449")
        assert_equal(Barcode::EAN13.new("9780553382686").to_isbn.to_s, "0553382683")
        assert_raise_message(RuntimeError, /Not bookland/) { 
            Barcode::EAN13.new("2320029051141").to_isbn
        }
        assert_raise_message(RuntimeError, /Invalid checksum/) {
            Barcode::EAN13.new("9781597800441").to_isbn
        }
    end

    def assert_raise_message(types, matcher, message = nil, &block)
        args = [types].flatten + [message]
        exception = assert_raise(*args, &block)
        assert_match matcher, exception.message, message
    end

end
