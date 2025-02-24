FilterField = Struct.new(:field, :column, :operator, :relation, :value, keyword_init: true) do
  def to_sql
    ApplicationRecord.sanitize_sql_for_conditions([ parameter, value ])
  end

  private

  def parameter
    case operator
    when :isNull then "#{column} IS #{value == "false" ? "NOT NULL" : "NULL"}"
    when :eq then "#{column} = ?"
    when :neq then "#{column} != ?"
    else
      raise ArgumentError, "Unsupported operator #{operator}"
    end
  end
end
