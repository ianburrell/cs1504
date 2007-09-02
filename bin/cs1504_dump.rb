#!/usr/bin/ruby -w

require "cs1504"
require "getoptlong"

clear = false
debug = false
device = "/dev/ttyS0"
opts = GetoptLong.new(
    [ "--clear", GetoptLong::NO_ARGUMENT ],
    [ "--debug", GetoptLong::NO_ARGUMENT ]
    [ "--debug", GetoptLong::REQUIRED_ARGUMENT ]
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
list.each { |code|
    $stdout.puts([ code[0], code[1], code[2].to_s ].join("|"))
}

if ! list.empty? && clear then
    reader.do_action { reader.clear_bar_codes() }
end
