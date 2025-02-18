class BeneficiaryField < SimpleColumnField
  def self.all
    @all ||= [
      self.new(name: "status", column: "status", description: "Must be one of #{Beneficiary.status.values.map { |t| "`#{t}`" }.join(", ")}."),
      self.new(name: "gender", column: "gender", description: "Must be one of `M` or `F`."),
      self.new(name: "disability_status", column: "disability_status", description: "Must be one of #{Beneficiary.disability_status.values.map { |t| "`#{t}`" }.join(", ")}."),
      self.new(name: "date_of_birth", column: "date_of_birth", description: "Date of birth in `YYYY-MM-DD` format."),
      self.new(name: "language_code", column: "language_code", description: "The [ISO ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) alpha-3 language code of the beneficiary."),
      self.new(name: "iso_country_code", column: "iso_country_code", description: "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary."),
      self.new(name: "address.iso_region_code", column: "beneficiary_addresses.iso_region_code", relation: :addresses, description: "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the address"),
      self.new(name: "address.administrative_division_level_2_code", column: "beneficiary_addresses.administrative_division_level_2_code", relation: :addresses, description: "The second-level administrative subdivision code of the address (e.g. district code)"),
      self.new(name: "address.administrative_division_level_2_name", column: "beneficiary_addresses.administrative_division_level_2_name", relation: :addresses, description: "The second-level administrative subdivision name of the address (e.g. district name)"),
      self.new(name: "address.administrative_division_level_3_code", column: "beneficiary_addresses.administrative_division_level_3_code", relation: :addresses, description: "The third-level administrative subdivision code of the address (e.g. commune code)"),
      self.new(name: "address.administrative_division_level_3_name", column: "beneficiary_addresses.administrative_division_level_3_name", relation: :addresses, description: "The third-level administrative subdivision name of the address (e.g. commune name)"),
      self.new(name: "address.administrative_division_level_4_code", column: "beneficiary_addresses.administrative_division_level_4_code", relation: :addresses, description: "The forth-level administrative subdivision code of the address (e.g. village code)"),
      self.new(name: "address.administrative_division_level_4_name", column: "beneficiary_addresses.administrative_division_level_4_name", relation: :addresses, description: "The forth-level administrative subdivision name of the address (e.g. village name)")
    ]
  end

  def self.find(name)
    result = all.find { |f| f.name == name }
    raise ArgumentError, "Unknown field #{name}" if result.nil?
    result
  end
end
