class AggregateDataQuery
  attr_reader :filters, :groups

  def initialize(options)
    @filters = options.fetch(:filters, {})
    @groups = Array(options.fetch(:groups))
  end

  def apply(scope)
    result = scope.where(filters).group(groups).count
    result.map.with_index do |(key, value), index|
      StatResult.new(groups:, key:, value:, sequence_number: index + 1)
    end
  end
end
