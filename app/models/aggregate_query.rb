class AggregateQuery
  attr_reader :scope, :group_by_fields

  def initialize(scope, group_by_fields)
    @scope = scope
    @group_by_fields = group_by_fields
  end

  def apply
    relation = joins_with.present? ? scope.joins(*joins_with) : scope
    relation.group(group_by_fields.map(&:column))
  end

  private

  def joins_with
    group_by_fields.map(&:association).compact_blank.uniq
  end
end
