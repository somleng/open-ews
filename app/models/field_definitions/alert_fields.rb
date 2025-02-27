module FieldDefinitions
  alerts = Alert.arel_table

  AlertFields = Collection.new([
    Field.new(name: "status", column: alerts[:status], schema: FilterSchema::ListType.define(:string, Alert.aasm.states.map { |s| s.name.to_s }), description: "Must be one of #{Alert.aasm.states.map { |t| "`#{t}`" }.join(", ")}.")
  ])
end
