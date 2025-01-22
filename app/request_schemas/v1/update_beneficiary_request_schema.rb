module V1
  class UpdateBeneficiaryRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:id).filled(:integer)
        required(:type).filled(:str?, eql?: "beneficiary")
        required(:attributes).value(:hash).schema do
          optional(:phone_number).filled(SchemaTypes::Number)
          optional(:iso_country_code).filled(SchemaTypes::UpcaseString, included_in?: Contact.iso_country_code.values)
          optional(:disability_status).maybe(:string, included_in?: Contact.disability_status.values)
          optional(:language_code).maybe(:string)
          optional(:date_of_birth).maybe(:date)
          optional(:gender).maybe(:string, included_in?: Contact.gender.values)
          optional(:metadata).maybe(:hash?)
        end
      end
    end

    attribute_rule(:phone_number).validate(:phone_number_format)
    attribute_rule(:phone_number) do |attributes|
      next unless account.contacts.where(msisdn: attributes.fetch(:phone_number)).where.not(id: resource.id).exists?

      key([ :data, :attributes, :phone_number ]).failure(text: "must be unique")
    end


    def output
      result = super
      result[:msisdn] = result.delete(:phone_number) if result.key?(:phone_number)
      result
    end
  end
end
