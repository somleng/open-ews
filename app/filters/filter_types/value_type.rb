module FilterTypes
  class ValueType
    def self.define(type)
      filter_class = Class.new(ApplicationFilter) do
        params do
          optional(:eq).filled(type)
          optional(:neq).filled(type)
          optional(:gt).filled(type)
          optional(:gteq).filled(type)
          optional(:lt).filled(type)
          optional(:lteq).filled(type)
          optional(:between).array(type, size?: 2)
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end
      end

      filter_class.schema
    end
  end
end
