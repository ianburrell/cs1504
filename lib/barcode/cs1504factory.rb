
module Barcode

require "barcode/ean13plus5"
require "barcode/ean13"
require "barcode/upca"
require "barcode/upcaplus5"

class CS1504Factory

    def CS1504Factory.create(type, code)
        barcode_class = type_to_class(type)
        raise "Unknown type #{type}" unless barcode_class
        return barcode_class.new(code)
    end

    def CS1504Factory.type_to_class(type)
        case type
        when "EAN-13"
            return EAN13
        when "EAN-13+5"
            return EAN13plus5
        when "UPCA"
            return UPCA
        when "UPCA+5"
            return UPCAplus5
        default
            return nil
        end
    end

end


end
