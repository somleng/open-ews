module V1
  class BeneficiaryRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "beneficiary")
        required(:attributes).value(:hash).schema do
          required(:phone_number).filled(:string)
          required(:iso_country_code).filled(Types::UpcaseString, included_in?: Contact.iso_country_code.values)
          optional(:language_code).maybe(:string)
          optional(:date_of_birth).maybe(:date)
          optional(:gender).maybe(Types::UpcaseString, included_in?: Contact.gender.values)
          optional(:metadata).value(:hash)

          optional(:address).filled(:hash).schema do
            required(:iso_country_code).filled(Types::UpcaseString, included_in?: Contact.iso_country_code.values)
            required(:iso_region_code).filled(:string, max_size?: 255)
            optional(:administrative_division_level_2_code).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_2_name).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_3_code).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_3_name).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_4_code).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_4_name).maybe(:string, max_size?: 255)
          end
        end
      end
    end

    attribute_rule(:phone_number).validate(:phone_number_format)
    attribute_rule(:phone_number) do |attributes|
      next unless account.contacts.where_msisdn(attributes.fetch(:phone_number)).exists?

      key([ :data, :attributes, :phone_number ]).failure(text: "must be unique")
    end

    attribute_rule(:address) do |attributes|
      next if attributes[:address].blank?

      validator = BeneficiaryAddressValidator.new(attributes[:address])
      next if validator.valid?

      validator.errors.each do |error|
        key([ :data, :attributes, :address, error.key ]).failure(text: error.message)
      end
    end

    def output
      result = super
      result[:msisdn] = PhonyRails.normalize_number(result.delete(:phone_number))
      result
    end
  end
end
