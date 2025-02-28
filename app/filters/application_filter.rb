class ApplicationFilter < ApplicationRequestSchema
  class_attribute :__field_collection__

  def self.has_fields(field_collection)
    self.__field_collection__ = field_collection

    params do
      field_collection.each do |field|
        optional(field.name.to_sym).filled(:hash).schema(field.schema)
      end
    end
  end

  def self.filter_contract
    this = self
    @filter_contract ||= Class.new(this) do
      params do
        optional(:filter).schema(this.schema)
      end

      rule(:filter).validate(contract: this)

      def output
        return {} if result[:filter].blank?

        self.class.superclass.new(input_params: result[:filter]).output
      end
    end
  end

  def output
    filters = super
    return {} if filters.blank?

    filters.map do |(filter, condition)|
      operator, value = condition.first
      field_definition = __field_collection__.find(filter.to_s)

      FilterField.new(field_definition:, operator:, value:)
    end
  end
end
