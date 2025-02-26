class FilterField
  attr_reader :field_definition, :operator, :value

  delegate :relation, :column, to: :field_definition

  def initialize(field_definition:, operator:, value:)
    @field_definition = field_definition
    @operator = operator
    @value = value
  end

  def to_sql
    column.public_send(operator_method, parameter_value)
  end

  private

  # NOTE: cast from user input operator to arel attribute's operator
  def operator_method
    case operator.to_sym
    when :isNull, :eq then :eq
    when :neq then :not_eq
    when :gt then :gt
    when :gte then :gteq
    when :lt then :lt
    when :lte then :lteq
    when :between then :between
    when :contains, :startsWith then :matches
    when :notContains then :does_not_match
    else
      raise ArgumentError, "Unsupported operator #{operator}"
    end
  end

  def parameter_value
    case operator
    when :contains, :notContains then "%#{value}%"
    when :startsWith then "#{value}%"
    when :between then Range.new(value[0], value[1])
    else value
    end
  end
end
