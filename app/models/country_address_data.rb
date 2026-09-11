module CountryAddressData
  class Configuration
    attr_reader :local_language, :address_field, :data

    def initialize(local_language:, address_field:, data:)
      @local_language = local_language
      @address_field = address_field
      @data = data
    end

    def self.blank
      new(local_language: nil, address_field: nil, data: -> { Collection.new })
    end

    def collection
      @collection ||= data.call
    end

    def tree
      @tree ||= collection.to_tree
    end
  end

  SETTINGS = {
    KH: Configuration.new(local_language: :km, address_field: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_3_code), data: -> { CountryAddressData::Cambodia.address_data }),
    LA: Configuration.new(local_language: :lo, address_field: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_2_code), data: -> { CountryAddressData::Laos.address_data }),
    NP: Configuration.new(local_language: :ne, address_field: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_2_code), data: -> { CountryAddressData::Nepal.address_data }),
    MM: Configuration.new(local_language: :my, address_field: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_5_code), data: -> { CountryAddressData::Myanmar.address_data })
  }

  def self.address_field(iso_country_code)
    return nil unless supported?(iso_country_code)

    SETTINGS.fetch(iso_country_code.to_sym).address_field
  end

  def self.address_data(iso_country_code)
    return Configuration.blank unless supported?(iso_country_code)

    SETTINGS.fetch(iso_country_code.to_sym)
  end

  def self.supported?(iso_country_code)
    return false if iso_country_code.blank?

    SETTINGS.key?(iso_country_code.to_sym)
  end
end
