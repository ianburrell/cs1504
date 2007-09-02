#!/usr/bin/ruby

require "barcode/cs1504"

while line = gets
    type, code, timestamp = line.split(/\|/)
    cc = Barcode::CS1504Code.new(code, type, timestamp)
    begin
        bc = cc.to_barcode()
        puts bc.to_isbn.to_s
    rescue
        $stderr.puts "#{type}:#{code} failed: #{$!}"
    end
end
