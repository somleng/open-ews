class AlertFilter < ApplicationFilter
  params do
    optional(:status).filled(included_in?: [ "queued", "completed" ])
  end

  def output
    result = super
    return {} if result.blank?

    result[:answered] = result.delete(:status) === "completed" if result.key?(:status)

    result.each_with_object({}) do |(filter, value), filters|
      filters[SimpleColumnField.new(name: filter, column: filter)] = value
    end
  end
end
