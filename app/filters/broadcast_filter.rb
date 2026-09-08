class BroadcastFilter < ApplicationFilter
  has_fields FieldDefinitions::BroadcastFields.concat(FieldDefinitions::TargetAreaFields)
end
