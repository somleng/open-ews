class AggregateDataQuery
  MAX_RESULTS = 10_000

  class TooManyResultsError < StandardError; end

  attr_reader :filter_fields, :group_by_fields

  def initialize(options)
    @filter_fields = options.fetch(:filter_fields, {})
    @group_by_fields = options.fetch(:group_by_fields)
  end

  def apply(scope)
    query = query_scope(scope).where(where_conditions).group(group_by)
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
    joins_with = group_by_fields.pluck(:relation) + filter_fields.keys.pluck(:relation)
    joins_with = joins_with.compact_blank.uniq
    scope = scope.joins(*joins_with) if joins_with.any?
    scope
  end

  def total_count(query)
    ApplicationRecord.from(query.select("1")).count
  end

  def group_by
    group_by_fields.map(&:column)
  end

  def where_conditions
    filter_fields.each_with_object({}) do |(filter, value), result|
      result[filter.column] = value
    end
  end
end
