class FilterField
  attr_reader :field_definition, :operator, :value

  delegate :relation, :column, to: :field_definition

  def initialize(field_definition:, operator:, value:)
    @field_definition = field_definition
    @operator = operator
    @value = value
  end

  def parameter
    case operator.to_sym
    when :isNull then "#{column} IS #{value == "false" ? "NOT NULL" : "NULL"}"
    when :eq then "#{column} = ?"
    when :neq then "#{column} != ?"
    when :gt then "#{column} > ?"
    when :gte then "#{column} >= ?"
    when :lt then "#{column} < ?"
    when :lte then "#{column} <= ?"
    when :between then "#{column} >= ? AND #{column} <= ?"
    when :contains, :startsWith then "#{column} ILIKE ?"
    when :notContains then "#{column} NOT ILIKE ?"
    else
      raise ArgumentError, "Unsupported operator #{operator}"
    end
  end

  def parameter_value
    case operator
    when :contains, :notContains then "%#{value}%"
    when :startsWith then "#{value}%"
    else value
    end
  end
end
