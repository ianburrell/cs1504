
module Barcode

require "barcode/ean13plus5"
require "barcode/ean13"
require "barcode/upca"
require "barcode/upcaplus5"

class CS1504Code < Barcode
    attr_reader :type, :timestamp

    def initialize(code, type, timestamp)
        super(code)
        @type = type
        @timestamp = timestamp
    end

    def to_barcode
        barcode_class = CS1504Code.type_to_class(@type)
        raise "Unknown type #{@type}" unless barcode_class
        return barcode_class.new(@code)
    end

    def CS1504Code.type_to_class(type)
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
