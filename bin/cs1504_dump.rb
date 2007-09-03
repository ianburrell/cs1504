#!/usr/bin/ruby -w

require "getoptlong"
require "cs1504"
require "barcode/cs1504code"

clear = false
debug = false
device = "/dev/ttyS0"
opts = GetoptLong.new(
    [ "--clear", GetoptLong::NO_ARGUMENT ],
    [ "--debug", GetoptLong::NO_ARGUMENT ],
    [ "--device", GetoptLong::REQUIRED_ARGUMENT ]
)
opts.each { |opt, arg|
    case opt
    when "--clear"
        clear = true
    when "--debug"
        debug = true
    when "--device"
        device = arg
    end
}

reader = CS1504.new(device)
reader.debug = debug
list = reader.get_bar_codes()
list.each { |elt|
    code = Barcode::CS1504Code.new_from_device(elt)
    $stdout.puts(code.to_s)
}

if ! list.empty? && clear then
    reader.do_action { reader.clear_bar_codes() }
end
