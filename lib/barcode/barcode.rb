module Barcode

class Barcode
    include Comparable
    attr_reader :code

    def initialize(code)
        required = required_length()
        if required && code.length != required then
            raise "#{type()} must be #{required} characters long"
        end
        @code = code
    end

    def Barcode.new_from_input(line)
        return new(line.chomp)
    end

    def <=>(other)
        @code <=> other.code
    end

    def to_s
        @code
    end

    def required_length
        return nil
    end

    def is_isbn
        return false
    end

    def to_barcode
        return self
    end
    
    def length
        return @code.length
    end

end

end
