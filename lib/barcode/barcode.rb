module Barcode

class Barcode
  attr_reader :code

  def initialize(code)
      required = required_length()
      if required && code.length != required then
          raise "#{type()} must be #{required} characters long"
      end
      @code = code
  end

  def <=>(other)
      @code <=> other.code
  end

  def to_s
      @code
  end

  def required_length
      return nil
  end

end

end
