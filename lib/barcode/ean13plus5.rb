module Barcode

require "barcode/ean13"

class EAN13plus5 < EAN13

    def required_length
        return 18
    end

    def type
        return "EAN-13+5"
    end

    def additional
        return @code[13, 5]
    end

end

end
