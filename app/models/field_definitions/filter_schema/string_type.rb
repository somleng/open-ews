module FieldDefinitions
  module FilterSchema
    class StringType
      def self.define(type = :string)
        Dry::Schema.Params do
          optional(:eq).filled(type)
          optional(:not_eq).filled(type)
          optional(:contains).filled(type)
          optional(:not_contains).filled(type)
          optional(:starts_with).filled(type)
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end
      end
    end
  end
end
