module V1
  class ContactRequestSchema < BaseRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "contact")
        required(:attributes).value(:hash).schema do
          required(:msisdn).filled(:string)
          required(:iso_country_code).filled(:string, included_in?: Contact.iso_country_code.values)
          optional(:language_code).maybe(:string)
          optional(:date_of_birth).maybe(:date)
          optional(:gender).maybe(:string, included_in?: Contact.gender.values)
          optional(:metadata).maybe(:hash?)

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
    rule do
      Rules.new(self).validate
    end

    def output
      result = super
      result[:msisdn] = PhonyRails.normalize_number(result.fetch(:msisdn)) if result.key?(:msisdn)
      result
    end

    class Rules < SchemaRules::JSONAPISchemaRules
      def validate
        return true if resource&.persisted?
        return key(:msisdn).failure(text: "can't be blank") if values[:msisdn].blank?

        key(:msisdn).failure(text: "must be unique") if contact_exists?
      end

      private

      def contact_exists?
        account.contacts.where_msisdn(values.fetch(:msisdn)).exists?
      end
    end
  end
end
