module V1
  class UpdateBeneficiaryRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:id).filled(:integer)
        required(:type).filled(:str?, eql?: "beneficiary")
        required(:attributes).value(:hash).schema do
          optional(:msisdn).filled(:string)
          optional(:language_code).maybe(:string)
          optional(:date_of_birth).maybe(:date)
          optional(:gender).maybe(:string, included_in?: Contact.gender.values)
          optional(:iso_country_code).maybe(:string, included_in?: Contact.iso_country_code.values)
          optional(:metadata).maybe(:hash?)
        end
      end
    end

    attribute_rule(:msisdn).validate(:phone_number_format)
    rule do
      BeneficiaryRequestSchema::Rules.new(self).validate
    end

    def output
      result = super
      result[:msisdn] = PhonyRails.normalize_number(result.fetch(:msisdn)) if result.key?(:msisdn)
      result
    end
  end
end
