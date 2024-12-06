module V1
  class ContactRequestSchema < BaseRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "contact")
        required(:attributes).value(:hash).schema do
          required(:msisdn).filled(:string)
          optional(:language_code).maybe(:string)
          optional(:date_of_birth).maybe(:date)
          optional(:gender).maybe(:string, included_in?: Contact.gender.values)
          optional(:metadata).maybe(:hash?)
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
