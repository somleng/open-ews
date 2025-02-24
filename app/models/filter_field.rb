FilterField = Struct.new(:field, :column, :operator, :relation, :value, keyword_init: true) do
  def to_sql
    ApplicationRecord.sanitize_sql_for_conditions([ parameter, parameter_value ])
  end

  private

  def parameter
    case operator.to_sym
    when :isNull then "#{column} IS #{value == "false" ? "NOT NULL" : "NULL"}"
    when :eq then "#{column} = ?"
    when :neq then "#{column} != ?"
    when :gt then "#{column} > ?"
    when :gte then "#{column} >= ?"
    when :lt then "#{column} < ?"
    when :lte then "#{column} <= ?"
    when :between then "#{column} >= ? and #{column} <= ?"
    when :contains then "#{column} ILIKE ?"
    when :notContains then "#{column} NOT ILIKE ?"
    else
      raise ArgumentError, "Unsupported operator #{operator}"
    end
  end

  def parameter_value
    case operator
    when :contains, :notContains then "%#{value}%"
    else value
    end
  end
end
