#!/usr/bin/ruby

require "barcode/cuecatcode"

while line = gets
    cc = Barcode::CueCatCode.new_from_input(line)
    puts cc.to_s
end
