class PhoneNumberType < ActiveRecord::Type::String
  AREA_CODE_COUNTRY_PREFIXES = [ "1" ].freeze

  PhoneNumber = Struct.new(:value, :country_code, :area_code, :e164, keyword_init: true) do
    def to_s
      value
    end

    def e164?
      e164
    end

    def sip?
      sip
    end

    def ==(other)
      if other.is_a?(self.class)
        value == other.value
      else
        value == other
      end
    end

    def possible_countries
      @possible_countries ||= e164? ? ISO3166::Country.find_all_country_by_country_code(country_code) : ISO3166::Country.all
    end

    def country
      possible_countries.first if possible_countries.one?
    end
  end

  attr_reader :parser

  def initialize(**options)
    super

    @parser = options.fetch(:parser) { PhoneNumberParser.new }
  end

  def cast(value)
    return if value.blank?
    return value if value.is_a?(PhoneNumber)

    value = value.gsub(/\D/, "")
    return if value.blank?

    return PhoneNumber.new(value:, e164: false) unless parser.valid?(value)

    country_code, area_code, = parser.split(value)
    PhoneNumber.new(
      value:,
      e164: true,
      country_code: country_code,
      area_code: (area_code if country_code.in?(AREA_CODE_COUNTRY_PREFIXES))
    )
  end

  def serialize(value)
    cast(value)&.value
  end
end
