class StatsQuery
  MAX_RESULTS = 10_000

  class TooManyResultsError < StandardError; end

  attr_reader :filter_fields, :group_by_fields

  def initialize(options)
    @filter_fields = options.fetch(:filter_fields, [])
    @group_by_fields = options.fetch(:group_by_fields)
  end

  def apply(scope)
    query = apply_filters(scope)
    query = apply_aggregate(query)

    raise TooManyResultsError if total_count(query) > MAX_RESULTS

    query.count.map.with_index do |(key, value), index|
      StatResult.new(
        groups: group_by_fields.map(&:name),
        key: Array(key),
        value:,
        sequence_number: index + 1
      )
    end
  end

  private

  def apply_filters(scope)
    FilterScopeQuery.new(scope, filter_fields).apply
  end

  def apply_aggregate(scope)
    AggregateQuery.new(scope, group_by_fields).apply
  end

  def total_count(query)
    ApplicationRecord.from(query.select("1")).count
  end
end
