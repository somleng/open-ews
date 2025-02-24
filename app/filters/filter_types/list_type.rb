module FilterTypes
  class ListType
    def self.define(values)
      filter_class = Class.new(ApplicationFilter) do
        params do
          optional(:eq).filled(:str?, included_in?: values)
          optional(:neq).filled(:str?, included_in?: values)
          optional(:isNull).filled(:str?, included_in?: [ "true", "false" ])
        end
      end

      filter_class.schema
    end
  end
end
