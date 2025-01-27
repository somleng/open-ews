class FilterScopeQuery
  attr_reader :scope, :filter_fields

  def initialize(scope, filter_fields)
    @scope = scope
    @filter_fields = filter_fields
  end

  def apply
    relation = joins_with.present? ? scope.joins(*joins_with) : scope
    relation.where(where_conditions)
  end

  private

  def joins_with
    filter_fields.map { |f, _| f.relation }.compact_blank.uniq
  end

  def where_conditions
    filter_fields.each_with_object({}) do |(filter, value), result|
      result[filter.column] = value
    end
  end
end
