module FieldDefinitions
  NotificationFields = Collection.new([
    Field.new(
      name: "status",
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::ListType.define(type: :string, options: Notification.status.values),
        query: FieldQuery.new(
          arel_column: Notification.arel_table[:status],
        )
      ),
      description: "Must be one of #{Notification.status.values.map { |t| "`#{t}`" }.join(", ")}."
    ),
    Field.new(
      name: "delivery_attempts_count",
      filter: BeneficiaryFilter.new(
        schema: FilterSchema::ValueType.define(type: :integer, type_options: { gteq?: 0, lteq?: 100 }),
        query: FieldQuery.new(
          arel_column: Notification.arel_table[:delivery_attempts_count],
        )
      ),
      description: "Number of delivery attempts. Must be an integer between 0 and 100."
    ),
    Field.new(
      name: "created_at",
      filter: Filter.timestamp(
        query: FieldQuery.new(
          arel_column: Notification.arel_table[:created_at],
        )
      ),
      description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the notification was created."
    ),
    Field.new(
      name: "completed_at",
      filter: Filter.timestamp(
        query: FieldQuery.new(
          arel_column: Notification.arel_table[:completed_at],
        )
      ),
      description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the notification was completed."
    ),
    *BeneficiaryFields.map do |field|
      Field.new(
        **field.to_h,
        prefix: [ "beneficiary", field.prefix ].compact.join("."),
        filter: Filter.new(
          schema: field.filter.schema,
          query: FieldQuery.new(
            **field.filter.query.to_h,
            association: { beneficiary: field.filter.query.association }
          )
        )
      )
    end
  ])
end
