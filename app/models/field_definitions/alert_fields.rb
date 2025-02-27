module FieldDefinitions
  alerts = Alert.arel_table
  beneficiaries = Beneficiary.arel_table

  AlertFields = Collection.new([
    Field.new(name: "status", column: alerts[:status], schema: FilterSchema::ListType.define(:string, Alert.aasm.states.map { |s| s.name.to_s }), description: "Must be one of #{Alert.aasm.states.map { |t| "`#{t}`" }.join(", ")}."),
    Field.new(name: "delivery_attempts_count", column: alerts[:delivery_attempts_count], schema: FilterSchema::ValueType.define(:integer), description: "Number of delivery attempts"),
    # beneficiary fields
    Field.new(name: "beneficiary.status", column: beneficiaries[:status], schema: FilterSchema::ListType.define(:string, Beneficiary.status.values), association: :beneficiary, description: "Must be one of #{Beneficiary.status.values.map { |t| "`#{t}`" }.join(", ")}."),
    Field.new(name: "beneficiary.gender", column: beneficiaries[:gender], schema: FilterSchema::ListType.define(Types::UpcaseString, Beneficiary.gender.values), association: :beneficiary, description: "Must be one of `M` or `F`."),
    Field.new(name: "beneficiary.disability_status", column: beneficiaries[:disability_status], schema: FilterSchema::ListType.define(:string, Beneficiary.disability_status.values), association: :beneficiary, description: "Must be one of #{Beneficiary.disability_status.values.map { |t| "`#{t}`" }.join(", ")}."),
    Field.new(name: "beneficiary.date_of_birth", column: beneficiaries[:date_of_birth], schema: FilterSchema::ValueType.define(:date), association: :beneficiary, description: "Date of birth in `YYYY-MM-DD` format."),
    Field.new(name: "beneficiary.language_code", column: beneficiaries[:language_code], schema: FilterSchema::StringType.define, association: :beneficiary, description: "The [ISO ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) alpha-3 language code of the beneficiary."),
    Field.new(name: "iso_country_code", column: beneficiaries[:iso_country_code], schema: FilterSchema::ListType.define(Types::UpcaseString, Beneficiary.iso_country_code.values), association: :beneficiary, description: "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary.")
  ])
end
