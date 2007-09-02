module Barcode

require "barcode/barcode"
require "barcode/isbn"

class EAN13 < Barcode

    def EAN13.new_with_check(code)
        throw "Code must be 12 characters long" unless code.length == 12
        return EAN13.new(code + checksum(code))
    end

    def required_length
        return 13
    end

    def type
        return "EAN-13"
    end

    def ean
        return @code[0, 13]
    end

    def check_digit
        return @code[12, 1]
    end

    def test_valid
        raise "Invalid checksum for #{code}" unless is_valid()
    end

    def is_valid
        return check_digit() == checksum()
    end

    def checksum
        return EAN13.checksum(@code)
    end

    def EAN13.checksum(code)
        sum = 0
        0.upto(11) do |i|
            digit = code[i] - 48
            weighting = (i % 2 == 0) ? 1 : 3
            sum += (weighting * digit)
        end
        sum = (10 - (sum % 10)) % 10
        return (48 + sum).chr
    end

    def to_isbn
        test_valid()
        # Bookland and Powells internal
        if is_isbn || @code[0,3] == '280' then
            return ISBN.new_with_check(@code[3, 9])
        # ISBN-13
        elsif @code[0, 3] == "979" then
            return self
        else
            raise "Not bookland"
        end
    end

    def is_isbn
        @code[0, 3] == "978"
    end

end

end
