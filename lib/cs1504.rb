#!/usr/bin/ruby -w

require "serialport.so"
require "date"

class CS1504
    attr_accessor :debug

    def initialize(port)
        @serial = SerialPort.new(port, 9600, 8, 1, SerialPort::ODD)
        @serial.flow_control = SerialPort::NONE
        @debug = 0
    end

    def serial
        @serial
    end

    def log_debug(str)
        $stderr.puts(str) if debug
    end

    def get_bar_codes
        wake_up()
        status = interrogate()
        bar_codes = upload()
        power_down()
        return parse_bar_codes(bar_codes)
    end

    def do_action
        wake_up()
        status = interrogate()
        yield
        power_down()
    end

    INTERROGATE               = 0x01
    CLEAR_BAR_CODES           = 0x02
    DOWNLOAD_PARAMETERS       = 0x03
    SET_DEFAULTS              = 0x04
    POWER_DOWN                = 0x05
    UPLOAD                    = 0x07
    UPLOAD_PARAMETERS         = 0x08
    SET_TIME                  = 0x09
    GET_TIME                  = 0x0a
    
    INVALID_COMMAND_NUMBER      = 5  
    NO_ERROR_ENCOUNTERED        = 6
    COMMAND_LRC_ERROR           = 7  
    RECEIVED_CHARACTER_ERROR    = 8  
    GENERAL_ERROR               = 9  

    @@error_messages = {
        INVALID_COMMAND_NUMBER      => 'Unsupported command',
        COMMAND_LRC_ERROR           => 'CRC error',
        RECEIVED_CHARACTER_ERROR    => 'Received character error',
        GENERAL_ERROR               => 'General error',
    }

    def is_data_available
        if @serial.dtr == 0
            @serial.dtr = 0
            sleep(0.175)
        end
        return @serial.cts
    end
    
    def wake_up
        if @serial.dtr == 1
            @serial.dtr = 0
            sleep(0.175)
        end
        @serial.dtr = 1
        sleep(0.1)
    end

    def interrogate
        send_command(INTERROGATE)
        recv_status()
        protocol_version = @serial.getc()
        system_status = @serial.getc()
        device_id = @serial.read(8)
        software_version = @serial.read(8)
        null = @serial.getc
        recv_crc()
        return {
            'protocol_version' => protocol_version,
            'system_status' => system_status,
            'device_id' => device_id,
            'software_version' => software_version,
        }
    end

    def clear_bar_codes
        send_command(CLEAR_BAR_CODES)
        recv_simple_response()
    end

    def download_parameters(param_values)
        send_command(DOWNLOAD_PARAMETERS)
        # TODO: incomplete
    end
    
    def upload_parameters(params)
        send_command(UPLOAD_PARAMETERS)
        recv_status()
        strings = recv_strings()
        recv_crc()
        return strings
    end

    def set_defaults
        send_command(SET_DEFAULTS, "\x01")
        recv_status()
        recv_strings()
        recv_crc()
    end  

    def power_down
        send_command(POWER_DOWN)
        recv_simple_response()
    end

    def upload
        send_command(UPLOAD)
        recv_status()
        serial = @serial.read(8)
        log_debug("serial: " + serial.dump)
        bar_codes = recv_strings()
        recv_crc()
        return bar_codes
    end

    def set_time(time)
        send_command(SET_TIME, make_time(time))
        recv_status()
        recv_strings()
        recv_crc()
    end

    def get_time
        send_command(GET_TIME)
        recv_status()
        strings = recv_strings()
        recv_crc()
        return parse_time(strings[0])
    end

    def make_time(time)
        [ time.sec, time.min, time.hour, time.day, time.mon, time.year - 2000 ].pack("CCCCCC")
    end
    
    def parse_time(string)
        array = string.unpack("CCCCCC")
        DateTime.new(array[5] + 2000, array[4], array[3], array[2], array[1], array[0])
    end

    def parse_bar_codes(strings)
        return strings.map { |string|
            [ parse_type(string), parse_code(string), parse_timestamp(string) ]
        }
    end

    def parse_type(string)
        return @@code_types[string[0]]
    end

    @@code_types = {
        0x16 => "Bookland",
        0x02 => "Codabar",
        0x0c => "Code 11",
        0x20 => "Code 32",
        0x03 => "Code 128",
        0x01 => "Code 39",
        0x13 => "Code 39 Full ASCII",
        0x07 => "Code 93",
        0x1d => "Composite",
        0x17 => "Coupon",
        0x04 => "D25",
        0x1b => "Data Matrix",
        0x0f => "EAN-128",
        0x0b => "EAN-13",
        0x4b => "EAN-13+2",
        0x8b => "EAN-13+5",
        0x0a => "EAN-8",
        0x4a => "EAN-8+2",
        0x8a => "EAN-8+5",
        0x05 => "IATA",
        0x19 => "ISBT-128",
        0x21 => "ISBT-128 Concatenated",
        0x06 => "ITF",
        0x28 => "Macro PDF",
        0x0E => "MSI",
        0x11 => "PDF-417",
        0x26 => "Postbar (Canada)",
        0x1e => "Postnet (US)",
        0x23 => "Postal (Australia)",
        0x22 => "Postal (Japan)",
        0x27 => "Postal (UK)",
        0x1c => "QR Code",
        0x31 => "RSS Limited",
        0x30 => "RSS-14",
        0x32 => "RSS Expanded",
        0x24 => "Signature",
        0x15 => "Trioptic Code 39",
        0x08 => "UPCA",
        0x48 => "UPCA+2",
        0x88 => "UPCA+5",
        0x09 => "UPCE",
        0x49 => "UPCE+2",
        0x89 => "UPCE+5",
        0x10 => "UPCE1",
        0x50 => "UPCE1+2",
        0x90 => "UPCE1+5",
    }

    def parse_code(string)
        return string[1 .. -5]
    end

    def parse_timestamp(string)
        timestamp = string[-4,4].unpack("N")[0]
        seconds = (timestamp >> 26) & 0x3F
        minutes = (timestamp >> 20) & 0x3F
        hours = (timestamp >> 15) & 0x1F
        days = (timestamp >> 10) & 0x1F
        months = (timestamp >> 6) & 0x0F
        years = timestamp & 0x3F
        return DateTime.new(years + 2000, months, days, hours, minutes, seconds)
    end

    def send_command(command, *args)
        sleep(0.1)
        command = make_command(command, args)
        log_debug("command: " + command.dump)
        @serial.write(command)
    end

    def recv_simple_response
        recv_status()
        null = @serial.getc()
        recv_crc()
    end

    def recv_status
        sleep(0.1)
        status = @serial.getc()
        log_debug("status: " + status.to_s)
        if status != NO_ERROR_ENCOUNTERED
            raise "Protocol error: " + status.to_s + " " + (@@error_messages[status] || "Unknown error")
        end
        stx = @serial.getc()
    end

    def recv_strings
        strings = []
        while true
            length = @serial.getc
            break if length == 0
            string = @serial.read(length)
            log_debug(length.to_s + ": " + string.dump)
            strings.push(string)
        end
        return strings
    end

    def recv_crc()
        crc = @serial.read(2)
        log_debug("crc: " + crc.dump)
    end

    def make_command(command, args=[])
        message = [ command, 2 ].pack("CC")
        args.each { |x|
            message += x.length.chr
            message += x
        }
        message += "\x00"
        message += crc(message)
        return message
    end

    def crc(message)
        w = 0xFFFF
        message.each_byte { |c|
            w = (w >> 8) ^ (@@ccittrev_tbl[(w % 256) ^ c])
        }
        w = ~w
        return [ (w >> 8), (w % 256) ].pack("CC")
    end

    @@ccittrev_tbl = [
        0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241, 
        0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440, 
        0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40, 
        0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841, 
        0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40, 
        0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41, 
        0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641, 
        0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040, 
        0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240, 
        0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441, 
        0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41, 
        0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840, 
        0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41, 
        0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40, 
        0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640, 
        0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041, 
        0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240, 
        0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441, 
        0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41, 
        0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840, 
        0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41, 
        0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40, 
        0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
        0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041, 
        0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241, 
        0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440, 
        0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40, 
        0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841, 
        0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40, 
        0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
        0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641, 
        0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040,
    ]
    
end

