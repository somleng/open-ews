module FilterTypes
  class ValueType
    def self.define(type)
      type_predicate = "#{type}?".to_sym
      filter_class = Class.new(ApplicationFilter) do
        params do
          optional(:eq).filled(type_predicate)
          optional(:neq).filled(type_predicate)
          optional(:gt).filled(type_predicate)
          optional(:gteq).filled(type_predicate)
          optional(:lt).filled(type_predicate)
          optional(:lteq).filled(type_predicate)
          optional(:between).array(type_predicate, size?: 2)
          optional(:is_null).filled(:str?, included_in?: [ "true", "false" ])
        end
      end

      filter_class.schema
    end
  end
end
