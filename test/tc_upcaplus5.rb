$: << File.dirname(__FILE__) + "/../lib"

require "test/unit"
require "barcode/upcaplus5"

class TC_UPCAplus5 < Test::Unit::TestCase

    def test_new
        bc = Barcode::UPCAplus5.new("12345678901234567")
        assert_equal(bc.code, "12345678901234567")
        assert_raise_message(RuntimeError, /UPC-A\+5 must be 17 characters long/) {
            Barcode::UPCAplus5.new("1234567890123456")
        }
        assert_raise_message(RuntimeError, /UPC-A\+5 must be 17 characters long/) {
            Barcode::UPCAplus5.new("123456789012345678")
        }
    end

    def test_methods
        bc = Barcode::UPCAplus5.new("12345678901234567")
        assert_equal(bc.type, "UPC-A+5")
        assert_equal(bc.category, "1")
        assert_equal(bc.manufacturer, "23456")
        assert_equal(bc.product, "78901")
        assert_equal(bc.check_digit, "2")
        assert_equal(bc.additional, "34567")
    end

    def test_checksum
        assert_equal(Barcode::UPCAplus5.checksum("03714500699"), "4")
        assert_equal(Barcode::UPCAplus5.checksum("07671400799"), "4")
    end

    def test_is_valid
        assert(Barcode::UPCAplus5.new("03714500699434340").is_valid)
        assert(Barcode::UPCAplus5.new("07671400799443616").is_valid)
        assert(! Barcode::UPCAplus5.new("07671400799043616").is_valid)
    end
       
    def test_to_ean13
        assert_equal(Barcode::UPCAplus5.new("03714500699434340").to_ean13.to_s, "0037145006994")
        assert_equal(Barcode::UPCAplus5.new("07671400799443616").to_ean13.to_s, "0076714007994")
        assert_raise_message(RuntimeError, /Invalid checksum/) {
            Barcode::UPCAplus5.new("07671400799043616").to_ean13
        }
    end

    def assert_raise_message(types, matcher, message = nil, &block)
        args = [types].flatten + [message]
        exception = assert_raise(*args, &block)
        assert_match matcher, exception.message, message
    end

end
