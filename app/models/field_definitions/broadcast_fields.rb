module FieldDefinitions
  BroadcastFields = Collection.new(
    [
      Field.new(name: "name", column: Broadcast.arel_table[:name], schema: FilterSchema::StringType.define, description: "The name of the broadcast."),
      Field.new(name: "status", column: Broadcast.arel_table[:status], schema: FilterSchema::ListType.define(type: :string, options: Broadcast.status.values), description: "Must be one of #{Broadcast.status.values.map { |t| "`#{t}`" }.join(", ")}."),
      Field.new(name: "channels", column: Broadcast.arel_table[:channel], schema: FilterSchema::ArrayType.define(included_in: Broadcast.channel.values), description: "Must be one of #{Broadcast.channel.values.map { |t| "`#{t}`" }.join(", ")}."),
      Field.new(name: "created_at", column: Broadcast.arel_table[:created_at], schema: FilterSchema::ValueType.define(type: :date_time, form_value_type: :datetime), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was created."),
      Field.new(name: "started_at", column: Broadcast.arel_table[:started_at], schema: FilterSchema::ValueType.define(type: :date_time, form_value_type: :datetime), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was started."),
      Field.new(name: "completed_at", column: Broadcast.arel_table[:completed_at], schema: FilterSchema::ValueType.define(type: :date_time, form_value_type: :datetime), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was completed."),
      *TargetAreaFields.where(category: :geocode).map do |field|
        field.clone(
          prefix: [ :target_areas, :geocode, field.prefix ].compact.join("."),
          association: :target_areas,
          query: ->(operator:, value:) do
            query_params = {
              administrative_level: field.attributes.fetch(:administrative_level),
              geocode: value
            }

            scope = case operator.to_sym
            when :eq
              Broadcast.target_areas_equal(**query_params)
            when :contains
              Broadcast.target_areas_contain(**query_params)
            end

            Broadcast.arel_table[:id].in(scope.select(:id).arel)
          end
        )
      end
    ]
  )
end
