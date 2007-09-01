$: << File.dirname(__FILE__) + "/../lib"

require "test/unit"
require "barcode/isbn"

class TC_ISBN < Test::Unit::TestCase

    def test_new
        bc = Barcode::ISBN.new("1234567890")
        assert_equal(bc.code, "1234567890")
        assert_raise_message(RuntimeError, /ISBN must be 10 characters long/) {
            Barcode::ISBN.new("123456789")
        }
        assert_raise_message(RuntimeError, /ISBN must be 10 characters long/) {
            Barcode::ISBN.new("12345678901")
        }
    end

    def test_type
        bc = Barcode::ISBN.new("1234567890")
        assert_equal(bc.type, "ISBN")
    end

    def test_check_digit
        bc = Barcode::ISBN.new("1234567890")
        assert_equal(bc.check_digit, "0")
    end

    def test_checksum
        assert_equal(Barcode::ISBN.checksum("159780044"), "9")
        assert_equal(Barcode::ISBN.checksum("055338268"), "3")
    end

    def test_is_valid
        assert(Barcode::ISBN.new("1597800449").is_valid)
        assert(! Barcode::ISBN.new("1597800448").is_valid)
    end
       
    def test_new_with_check
        assert_equal(Barcode::ISBN.new_with_check("159780044").to_s, "1597800449")
        assert_equal(Barcode::ISBN.new_with_check("055338268").to_s, "0553382683")
    end
 
    def test_to_isbn
        assert(Barcode::ISBN.new("1597800449").to_isbn.to_s, "1597800449")
        assert_raise_message(RuntimeError, /Invalid checksum/) {
            Barcode::ISBN.new("1597800441").to_isbn
        }
    end

    def test_to_ean13
        assert_equal(Barcode::ISBN.new("1597800449").to_ean13.to_s, "9781597800440")
        assert_equal(Barcode::ISBN.new("0553382683").to_ean13.to_s, "9780553382686")
        assert_raise_message(RuntimeError, /Invalid checksum/) {
            Barcode::ISBN.new("1597800441").to_ean13
        }
    end

    def assert_raise_message(types, matcher, message = nil, &block)
        args = [types].flatten + [message]
        exception = assert_raise(*args, &block)
        assert_match matcher, exception.message, message
    end

end
