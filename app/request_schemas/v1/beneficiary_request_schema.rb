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
            required(:iso_region_code).filled(:string)
            optional(:administrative_division_level_2_code).maybe(:string)
            optional(:administrative_division_level_2_name).maybe(:string)
            optional(:administrative_division_level_3_code).maybe(:string)
            optional(:administrative_division_level_3_name).maybe(:string)
            optional(:administrative_division_level_4_code).maybe(:string)
            optional(:administrative_division_level_4_name).maybe(:string)
          end
        end
      end
    end

    attribute_rule(:phone_number).validate(:phone_number_format)
    rule(data: :attributes) do
      Rules.new(self).validate
    end

    def output
      result = super
      result[:msisdn] = PhonyRails.normalize_number(result.delete(:phone_number))
      result
    end

    class Rules < SchemaRules::JSONAPISchemaRules
      def validate
        if resource.blank?
          return key(:phone_number).failure(text: "can't be blank") if values[:phone_number].blank?

          key(:phone_number).failure(text: "must be unique") if contact_exists?
        elsif values[:phone_number].present?
          key(:phone_number).failure(text: "must be unique") if contact_exists?
        end
      end

      private

      def contact_exists?
        relation = account.contacts.where_msisdn(values.fetch(:phone_number))
        relation = relation.where.not(id: resource.id) if resource.present?
        relation.exists?
      end
    end
  end
end
