module FilterTypes
  class StringType
    def self.define
      filter_class = Class.new(ApplicationFilter) do
        params do
          optional(:eq).filled(:str?)
          optional(:neq).filled(:str?)
          optional(:contains).filled(:str?)
          optional(:notContains).filled(:str?)
          optional(:startsWith).filled(:str?)
          optional(:isNull).filled(:str?, included_in?: [ "true", "false" ])
        end
      end

      filter_class.schema
    end
  end
end
