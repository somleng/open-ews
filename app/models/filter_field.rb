class FilterField
  attr_reader :field_definition, :operator, :value

  delegate :association, :column, to: :field_definition

  def initialize(field_definition:, operator:, value:)
    @field_definition = field_definition
    @operator = operator.to_sym
    @value = value
  end

  def to_query
    column.public_send(operator_method, filter_value)
  end

  private

  # NOTE: cast from user input operator to arel attribute's predications
  # https://www.rubydoc.info/gems/arel/Arel/Predications
  def operator_method
    case operator
    when :eq, :not_eq, :gt, :gteq, :lt, :lteq, :between then operator
    when :contains, :starts_with then :matches
    when :not_contains then :does_not_match
    when :is_null then value ? :eq : :not_eq
    else
      raise ArgumentError, "Unsupported operator #{operator}"
    end
  end

  def filter_value
    case operator
    when :is_null then nil
    when :contains, :not_contains then "%#{value}%"
    when :starts_with then "#{value}%"
    when :between then Range.new(value[0], value[1])
    else value
    end
  end
end
