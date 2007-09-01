module Barcode

require "barcode/upca"
require "barcode/isbn"

class UPCAplus5 < UPCA

    def required_length
        return 17
    end

    def type
        return "UPC-A+5"
    end

    def to_isbn
        prefix = manufacturer()
        suffix = additional()
        publisher = manufacturer_to_publisher(prefix)
        if publisher then
            return ISBN.new(publisher + suffix.substring(publisher.length() - 4))
        else
            throw "Unknown manufacturer: " + prefix
        end
    end

    def additional
        return @code[12, 5]
    end

end

end
