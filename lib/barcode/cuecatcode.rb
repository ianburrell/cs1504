module Barcode

require "barcode/cuecatfactory"
require "barcode/cuecatdecoder"

def CueCatCode < Barcode
    attr_reader :type, :serial

    def initialize(code, type, serial)
        super(code)
        @type = type
        @serial = serial
    end

    def CueCatCode.new_from_input(encoded)
        serial, type, code = CueCatDecoder.decode_line(encoded)
        return new(code, type, serial)
    end

    def encode
        return CueCatDecoder.encode_line(@serial, @type, @code)
    end

    def is_valid
        return to_barcode.is_valid
    end

    def to_isbn
        return to_barcode.to_isbn
    end

    def to_barcode
        return CueCatFactory.create(@type, @code)
    end

end

end
