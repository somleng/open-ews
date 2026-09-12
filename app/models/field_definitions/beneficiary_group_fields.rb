module FieldDefinitions
  BeneficiaryGroupFields = Collection.new(
    [
      Field.new(
        name: "name",
        filter: Filter.new(
          schema: FilterSchema::StringType.define,
          query: FieldQuery.new(
            arel_column: BeneficiaryGroup.arel_table[:name],
          )
        ),
        description: "A friendly name for the group."
      )
    ]
  )
end
