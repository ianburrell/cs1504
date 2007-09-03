module Barcode

require "base64"
require "enumerator"

class CueCatDecoder

    def CueCatDecoder.decode_field(field)
        translated = field.tr("a-zA-Z0-9+\\-=", "A-Za-z0-9+/=")
        decoded = Base64.decode64(translated)
        xored = decoded.enum_for(:each_byte).map { |char| (char ^ 67).chr }
        return xored.join("")
    end

    def CueCatDecoder.decode_line(line)
        fields = line.split(".")
        fields.shift()
        return fields.map { |field| decode_field(field) }
    end

    def CueCatDecoder.encode_field(field)
        xored = field.enum_for(:each_byte).map { |char| (char ^ 67).chr }
        encoded = encode64(xored.join(""))
        return encoded.tr("A-Za-z0-9+/=", "a-zA-Z0-9+\\-=")
    end

    def CueCatDecoder.encode_line(serial, type, data)
        fields = [ serial, type, date ]
        encoded_fields = fields.map { |field| encode_field(field) }
        return "." + encoded_fields.join(".") + ".\n"
    end

end

end
