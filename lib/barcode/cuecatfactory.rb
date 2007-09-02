
module Barcode

require "barcode/ean13plus5"
require "barcode/ean13"
require "barcode/upca"
require "barcode/upcaplus5"

class CueCatFactory

    def CueCatFactory.create(type, code)
        barcode_class = type_to_class(type)
        raise "Unknown type #{type}" unless barcode_class
        return barcode_class.new(code)
    end

    def CueCatFactory.type_to_class(type)
        case type
        when "UPA"
            return UPCA
        when "UA5"
            return UPCAplus5
        when "E13", "IBN"
            return EAN13
        when "E35", "IB5"
            return EAN13plus5
        default
            return nil
        end
    end

end

end
