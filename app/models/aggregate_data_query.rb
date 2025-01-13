class AggregateDataQuery
  MAX_RESULTS = 10_000

  class TooManyResultsError < StandardError; end

  attr_reader :filters, :group_by_fields

  def initialize(options)
    @filters = options.fetch(:filters, {})
    @group_by_fields = options.fetch(:group_by_fields)
  end

  def apply(scope)
    query = query_scope(scope).where(filters).group(group_by)
    raise TooManyResultsError if total_count(query) > MAX_RESULTS

    result = query.count
    result.map.with_index do |(key, value), index|
      StatResult.new(
        groups: group_by_fields.map(&:name),
        key: Array(key),
        value:,
        sequence_number: index + 1
      )
    end
  end

  private

  def query_scope(scope)
    joins_with = group_by_fields.pluck(:relation).compact_blank
    scope = scope.joins(*joins_with) if joins_with.any?
    scope
  end

  def total_count(query)
    ApplicationRecord.from(query.select("1")).count
  end

  def group_by
    group_by_fields.map(&:column)
  end
end
