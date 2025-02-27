module FilterTypes
  class StringType
    def self.define(type = :string)
      filter_class = Class.new(ApplicationFilter) do
        params do
          optional(:eq).filled(type)
          optional(:neq).filled(type)
          optional(:contains).filled(type)
          optional(:not_contains).filled(type)
          optional(:starts_with).filled(type)
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end
      end

      filter_class.schema
    end
  end
end
