class AlertFilter < ApplicationFilter
  params do
    optional(:status).filled(:hash?).schema(FilterTypes::ListType.define(Alert.aasm.states.map { |s| s.name.to_s }))
  end

  def output
    result = super
    return {} if result.blank?

    result.map do |(filter, condition)|
      operator, value = condition.first

      FilterField.new(
        field: filter,
        column: filter,
        operator: operator,
        value: value
      )
    end
  end
end
