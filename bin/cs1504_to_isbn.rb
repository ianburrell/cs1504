#!/usr/bin/ruby

require "barcode/cs1504"

while line = gets
    begin 
        type, code, timestamp = line.split(/\|/)
        bc = Barcode::CS1504Factory.new(type, code)
        puts bc.to_isbn.to_s
    rescue
        $stderr.puts "#{type}:#{code} failed: #{$!}"
    end
end
