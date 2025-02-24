class AlertFilter < ApplicationFilter
  params do
    optional(:status).filled(included_in?: Alert.aasm.states.map { |s| s.name.to_s })
  end

  def output
    result = super
    return {} if result.blank?

    result.each_with_object({}) do |(filter, value), filters|
      filters[SimpleColumnField.new(name: filter, column: filter)] = value
    end
  end
end
