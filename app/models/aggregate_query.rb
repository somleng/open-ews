class AggregateQuery
  attr_reader :scope, :group_by_fields

  def initialize(scope, group_by_fields)
    @scope = scope
    @group_by_fields = group_by_fields
  end

  def apply
    scope.joins(joins_with).group(group_columns)
  end

  private

  def joins_with
    group_by_fields.map(&:association).compact_blank.uniq
  end

  def group_columns
    group_by_fields.map(&:column)
  end
end
