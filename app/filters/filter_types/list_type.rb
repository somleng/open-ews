module FilterTypes
  class ListType
    def self.define(type, values)
      filter_class = Class.new(ApplicationFilter) do
        params do
          optional(:eq).filled(type, included_in?: values)
          optional(:neq).filled(type, included_in?: values)
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end
      end

      filter_class.schema
    end
  end
end
