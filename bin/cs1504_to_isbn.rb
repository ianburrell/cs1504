#!/usr/bin/ruby

require "barcode/cs1504factory"
require "barcode/upctoisbn"

Barcode::UPCtoISBN.load()

while line = gets
    begin 
        type, code, timestamp = line.split(/\|/)
        bc = Barcode::CS1504Factory.create(type, code)
        Barcode::UPCtoISBN.record(bc)
        puts bc.to_isbn.to_s
    rescue => error
        $stderr.puts "#{type}|#{code}: #{error}"
    end
end

Barcode::UPCtoISBN.save()
