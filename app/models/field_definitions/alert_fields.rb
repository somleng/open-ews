module FieldDefinitions
  alerts = Alert.arel_table

  beneficiary_fields = BeneficiaryFields.map do |field|
    if field.association.blank?
      field.clone(name: "beneficiary.#{field.name}", association: :beneficiary)
    elsif field.name.starts_with?("address.")
      field.clone(name: "beneficiary.#{field.name}", association: { beneficiary: :addresses })
    else
      raise StandardError, "unsupported fields #{field.name}"
    end
  end

  AlertFields = Collection.new([
    Field.new(name: "status", column: alerts[:status], schema: FilterSchema::ListType.define(:string, Alert.aasm.states.map { |s| s.name.to_s }), description: "Must be one of #{Alert.aasm.states.map { |t| "`#{t}`" }.join(", ")}."),
    Field.new(name: "delivery_attempts_count", column: alerts[:delivery_attempts_count], schema: FilterSchema::ValueType.define(:integer), description: "Number of delivery attempts"),
    *beneficiary_fields
  ])
end
