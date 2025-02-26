module FieldDefinitions
  beneficiaries = Beneficiary.arel_table
  addresses = BeneficiaryAddress.arel_table

  BeneficiaryFields = Collection.new([
    Field.new(name: "status", column: beneficiaries[:status], schema: FilterTypes::ListType.define(Beneficiary.status.values), description: "Must be one of #{Beneficiary.status.values.map { |t| "`#{t}`" }.join(", ")}."),
    Field.new(name: "gender", column: beneficiaries[:gender], schema: FilterTypes::ListType.define(Beneficiary.gender.values), description: "Must be one of `M` or `F`."),
    Field.new(name: "disability_status", column: beneficiaries[:disability_status], schema: FilterTypes::ListType.define(Beneficiary.disability_status.values), description: "Must be one of #{Beneficiary.disability_status.values.map { |t| "`#{t}`" }.join(", ")}."),
    Field.new(name: "date_of_birth", column: beneficiaries[:date_of_birth], schema: FilterTypes::ValueType.define(:date), description: "Date of birth in `YYYY-MM-DD` format."),
    Field.new(name: "language_code", column: beneficiaries[:language_code], schema: FilterTypes::StringType.define, description: "The [ISO ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) alpha-3 language code of the beneficiary."),
    Field.new(name: "iso_country_code", column: beneficiaries[:iso_country_code], schema: FilterTypes::ListType.define(Beneficiary.iso_country_code.values), description: "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary."),
    Field.new(name: "address.iso_region_code", column: addresses[:iso_region_code], schema: FilterTypes::StringType.define, association: :addresses, description: "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the address"),
    Field.new(name: "address.administrative_division_level_2_code", column: addresses[:administrative_division_level_2_code], schema: FilterTypes::StringType.define, association: :addresses, description: "The second-level administrative subdivision code of the address (e.g. district code)"),
    Field.new(name: "address.administrative_division_level_2_name", column: addresses[:administrative_division_level_2_name], schema: FilterTypes::StringType.define, association: :addresses, description: "The second-level administrative subdivision name of the address (e.g. district name)"),
    Field.new(name: "address.administrative_division_level_3_code", column: addresses[:administrative_division_level_3_code], schema: FilterTypes::StringType.define, association: :addresses, description: "The third-level administrative subdivision code of the address (e.g. commune code)"),
    Field.new(name: "address.administrative_division_level_3_name", column: addresses[:administrative_division_level_3_name], schema: FilterTypes::StringType.define, association: :addresses, description: "The third-level administrative subdivision name of the address (e.g. commune name)"),
    Field.new(name: "address.administrative_division_level_4_code", column: addresses[:administrative_division_level_4_code], schema: FilterTypes::StringType.define, association: :addresses, description: "The forth-level administrative subdivision code of the address (e.g. village code)"),
    Field.new(name: "address.administrative_division_level_4_name", column: addresses[:administrative_division_level_4_name], schema: FilterTypes::StringType.define, association: :addresses, description: "The forth-level administrative subdivision name of the address (e.g. village name)")
  ])
end
