module V1
  class BeneficiaryRequestSchema < BaseRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "beneficiary")
        required(:attributes).value(:hash).schema do
          required(:msisdn).filled(:string)
          required(:iso_country_code).filled(Types::UpcaseString, included_in?: Contact.iso_country_code.values)
          optional(:language_code).maybe(:string)
          optional(:date_of_birth).maybe(:date)
          optional(:gender).maybe(Types::UpcaseString, included_in?: Contact.gender.values)
          optional(:metadata).value(:hash)

          optional(:address).filled(:hash).schema do
            optional(:iso_region_code).maybe(:string)
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

    attribute_rule(:msisdn).validate(:phone_number_format)
    rule(data: :attributes) do
      Rules.new(self).validate
    end

    def output
      result = super
      result[:msisdn] = PhonyRails.normalize_number(result.fetch(:msisdn)) if result.key?(:msisdn)
      result
    end

    class Rules < SchemaRules::JSONAPISchemaRules
      def validate
        if resource.blank?
          return key(:msisdn).failure(text: "can't be blank") if values[:msisdn].blank?

          key(:msisdn).failure(text: "must be unique") if contact_exists?
        elsif values[:msisdn].present?
          key(:msisdn).failure(text: "must be unique") if contact_exists?
        end
      end

      private

      def contact_exists?
        relation = account.contacts.where_msisdn(values.fetch(:msisdn))
        relation = relation.where.not(id: resource.id) if resource.present?
        relation.exists?
      end
    end
  end
end
