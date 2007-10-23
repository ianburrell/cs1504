#!/usr/bin/ruby

require "getoptlong"
require "barcode/upctoisbn"

type = "cs1504"
opts = GetoptLong.new(
    [ "--type", GetoptLong::REQUIRED_ARGUMENT ]
)
opts.each { |opt, arg|
    case opt
    when "--type"
        type = arg
    end
}

case type
when "cs1504"
    require "barcode/cs1504code"
    barcode_class = Barcode::CS1504Code
when "cuecat"
    require "barcode/cuecatcode"
    barcode_class = Barcode::CuecatCode
end

Barcode::UPCtoISBN.load()

while line = gets
    begin 
        cc = barcode_class.new_from_input(line)
        bc = cc.to_barcode()
        Barcode::UPCtoISBN.record(bc)
        puts bc.to_isbn.to_s
    rescue => error
        $stderr.puts "#{type}|#{code}: #{error}"
    end
end

Barcode::UPCtoISBN.save()
