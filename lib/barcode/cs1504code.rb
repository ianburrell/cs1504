module Barcode

require "barcode/cs1504factory"

class CS1504Code < Barcode
    attr_reader :type, :timestamp

    def initialize(code, type, timestamp)
        super(code)
        @type = type
        @timestamp = timestamp
    end
      
    def CS1504Code.new_from_input(line)
        type, code, timestamp = line.split("/\|/")
        return new(code, type, Date.new(timestamp))
    end

    def is_valid
        return to_barcode.is_valid
    end

    def to_isbn
        return to_barcode.to_isbn
    end

    def to_barcode
        return CS1504Factory.create(type, code)
    end

end

end
