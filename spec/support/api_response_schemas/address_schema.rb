module APIResponseSchema
  AddressSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "address")

    required(:attributes).schema do
      required(:iso_country_code).filled(:str?)
      required(:iso_region_code).filled(:str?)
      required(:administrative_division_level_2_name).maybe(:str?)
      required(:administrative_division_level_2_code).maybe(:str?)
      required(:administrative_division_level_3_code).maybe(:str?)
      required(:administrative_division_level_3_name).maybe(:str?)
      required(:administrative_division_level_4_code).maybe(:str?)
      required(:administrative_division_level_4_name).maybe(:str?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
