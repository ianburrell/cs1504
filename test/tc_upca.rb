$: << File.dirname(__FILE__) + "/../lib"

require "test/unit"
require "barcode/upca"

class TC_UPCA < Test::Unit::TestCase

    def test_new
        bc = Barcode::UPCA.new("123456789012")
        assert_equal(bc.code, "123456789012")
        assert_raise_message(RuntimeError, /UPC-A must be 12 characters long/) {
            Barcode::UPCA.new("12345678901")
        }
        assert_raise_message(RuntimeError, /UPC-A must be 12 characters long/) {
            Barcode::UPCA.new("1234567890123")
        }
    end

    def test_type
        bc = Barcode::UPCA.new("123456789012")
        assert_equal(bc.type, "UPC-A")
    end

    def test_check_digit
        bc = Barcode::UPCA.new("123456789012")
        assert_equal(bc.check_digit, "2")
    end

    def test_checksum
        assert_equal(Barcode::UPCA.checksum("03980005669"), "6")
        assert_equal(Barcode::UPCA.checksum("09466400728"), "4")
    end

    def test_is_valid
        assert(Barcode::UPCA.new("039800056696").is_valid)
        assert(! Barcode::UPCA.new("039800056695").is_valid)
    end
       
    def test_to_ean13
        assert_equal(Barcode::UPCA.new("039800056696").to_ean13.to_s, "0039800056696")
        assert_equal(Barcode::UPCA.new("094664007284").to_ean13.to_s, "0094664007284")
        assert_raise_message(RuntimeError, /Invalid checksum/) {
            Barcode::UPCA.new("039800056695").to_ean13
        }
    end

    def assert_raise_message(types, matcher, message = nil, &block)
        args = [types].flatten + [message]
        exception = assert_raise(*args, &block)
        assert_match matcher, exception.message, message
    end

end
