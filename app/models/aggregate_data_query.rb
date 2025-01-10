class AggregateDataQuery
  MAX_RESULTS = 10_000

  class TooManyResultsError < StandardError; end

  attr_reader :filters, :groups

  def initialize(options)
    @filters = options.fetch(:filters, {})
    @groups = options.fetch(:groups)
  end

  def apply(scope)
    query = scope.where(filters).group(group_by)
    raise TooManyResultsError if total_count(query) > MAX_RESULTS

    result = query.count
    result.map.with_index do |(key, value), index|
      StatResult.new(groups:, key: Array(key), value:, sequence_number: index + 1)
    end
  end

  private

  def total_count(query)
    ApplicationRecord.from(query.select("1")).count
  end

  def group_by
    groups.map(&:column)
  end
end
