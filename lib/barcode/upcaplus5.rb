module Barcode

require "barcode/upca"
require "barcode/isbn"
require "barcode/upctoisbn"

class UPCAplus5 < UPCA

    def required_length
        return 17
    end

    def type
        return "UPC-A+5"
    end

    def to_isbn
        prefix = category() + manufacturer()
        suffix = additional()
        publisher = UPCtoISBN.manufacturer_to_publisher(prefix)
        if publisher then
            return ISBN.new_with_check(publisher + suffix)
        else
            raise "Unknown manufacturer: " + prefix
        end
    end

    def additional
        return @code[12, 5]
    end

end

end
