class FilterScopeQuery
  attr_reader :scope, :filter_fields

  def initialize(scope, filter_fields)
    @scope = scope
    @filter_fields = filter_fields
  end

  def apply
    relation = joins_with.present? ? scope.joins(*joins_with) : scope
    apply_filters(relation)
  end

  private

  def joins_with
    filter_fields.map { |f| f.association }.compact_blank.uniq
  end

  def apply_filters(relation)
    filter_fields.each do |filter|
      relation = relation.where(filter.to_query)
    end

    relation
  end
end
