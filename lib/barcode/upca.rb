module Barcode

require "barcode/barcode"
require "barcode/ean13"

class UPCA < Barcode

    def required_length
        return 12
    end

    def type
        return "UPC-A"
    end

    def upc
        return @code[0, 12]
    end

    def category
        return @code[0, 1]
    end

    def manufacturer
        return @code[1, 5]
    end

    def product
        return @code[6, 5]
    end

    def check_digit
        return @code[11, 1]
    end

    def test_valid
        raise "Invalid checksum for #{code}" unless is_valid()
    end

    def is_valid
        return check_digit() == checksum()
    end

    def checksum
        UPCA.checksum(@code)
    end

    def UPCA.checksum(code)
        sum = 0
        0.upto(10) do |i|
            digit = code[i] - 48
            weighting = (i % 2 == 0) ? 3 : 1
            sum += (weighting * digit)
        end
        sum = (10 - (sum % 10)) % 10
        return (48 + sum).chr
    end
    
    def to_ean13
        test_valid()
        return EAN13.new("0" + upc)
    end

end

end
