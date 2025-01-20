class PhoneNumberParser
  attr_reader :parser

  def initialize(parser: Phony)
    @parser = parser
  end

  def valid?(value)
    return false if value.starts_with?("0")

    parser.plausible?(value)
  end

  def split(value)
    raise ArgumentError, "Not E-164 number" unless valid?(value)

    parser.split(value)
  end
end
