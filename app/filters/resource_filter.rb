class ResourceFilter < ApplicationFilter
  class_attribute :__field_collection__

  def self.has_fields(field_collection)
    self.__field_collection__ = field_collection

    params do
      field_collection.each do |field|
        optional(field.name.to_sym).schema(field.schema)
      end
    end
  end

  def output
    result = super
    return {} if result.blank?

    result.map do |(filter, condition)|
      operator, value = condition.first
      field_definition = __field_collection__.find(filter.to_s)

      FilterField.new(field_definition:, operator:, value:)
    end
  end
end
