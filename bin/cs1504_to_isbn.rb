#!/usr/bin/ruby

require "barcode/cs1504code"
require "barcode/upctoisbn"

Barcode::UPCtoISBN.load()

while line = gets
    begin 
        cc = Barcode::CS1504Code.new_from_input(line)
        bc = cc.to_barcode()
        Barcode::UPCtoISBN.record(bc)
        puts bc.to_isbn.to_s
    rescue => error
        $stderr.puts "#{cc.type}|#{cc.code}: #{error}"
    end
end

Barcode::UPCtoISBN.save()
