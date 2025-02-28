class FilterScopeQuery
  attr_reader :scope, :filter_fields

  def initialize(scope, filter_fields)
    @scope = scope
    @filter_fields = filter_fields
  end

  def apply
    scope.joins(joins_with).where(conditions)
  end

  private

  def joins_with
    filter_fields.map(&:association).compact_blank.uniq
  end

  def conditions
    filter_fields.map(&:to_query).reduce(:and)
  end
end
