
module Barcode

require "barcode/barcode"
require "barcode/ean13"

class ISBN < Barcode

    def ISBN.new_with_check(code)
        throw "Code must be 9 characters long: #{code}" unless code.length == 9
        return ISBN.new(code + checksum(code))
    end

    def required_length
        return 10
    end

    def type
        return "ISBN"
    end

    def check_digit
        return @code[9, 1]
    end

    def test_valid
        raise "Invalid checksum for #{code}" unless is_valid()
    end

    def is_valid
        return check_digit() == checksum()
    end

    def checksum
        return ISBN.checksum(@code)
    end

    def ISBN.checksum(code)
        sum = 0
        0.upto(8) do |i|
            digit = code[i] - 48
            sum += ((10 - i) * digit)
        end
        sum = (11 - (sum % 11)) % 11
        if sum == 10 then
            return "X";
        else
            return (48 + sum).chr
        end
    end

    def is_isbn
        return true
    end

    def to_isbn
        test_valid()
        return self
    end

    def to_ean13
        test_valid()
        return EAN13.new_with_check("978" + @code[0, 9])
    end

end

end
