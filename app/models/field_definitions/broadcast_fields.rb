module FieldDefinitions
  broadcasts = Broadcast.arel_table


  BroadcastFields = Collection.new([
    Field.new(name: "status", column: broadcasts[:status], schema: FilterSchema::ListType.define(:string, Broadcast.aasm.states.map { |s| s.name.to_s }), description: "Must be one of #{Broadcast.aasm.states.map { |t| "`#{t}`" }.join(", ")}."),
    Field.new(name: "channel", column: broadcasts[:channel], schema: FilterSchema::ListType.define(:string, Broadcast.channel.values), description: "Must be one of #{Broadcast.channel.values.map { |t| "`#{t}`" }.join(", ")}.")
  ])
end
