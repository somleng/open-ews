module FieldDefinitions
  module FilterSchema
    class ListType
      def self.define(type, values)
        Dry::Schema.Params do
          optional(:eq).filled(type, included_in?: values)
          optional(:not_eq).filled(type, included_in?: values)
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end
      end
    end
  end
end
