#!/usr/bin/ruby -w

require "cs1504"
require "getoptlong"

clear = false
debug = false
opts = GetoptLong.new(
    [ "--clear", GetoptLong::NO_ARGUMENT ],
    [ "--debug", GetoptLong::NO_ARGUMENT ]
)
opts.each { |opt, arg|
    case opt
    when "--clear"
        clear = true
    when "--debug"
        debug = true
    end
}

reader = CS1504.new("/dev/ttyS0")
reader.debug = debug
list = reader.get_bar_codes()
list.each { |code|
    $stdout.puts([ code[0], code[1], code[2].to_s ].join("|"))
}

if ! list.empty? && clear then
    reader.do_action { reader.clear_bar_codes() }
end
