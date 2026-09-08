class FilterField
  attr_reader :association, :column, :operator, :value, :query

  def initialize(**options)
    @operator = options.fetch(:operator).to_sym
    @value = options.fetch(:value)
    @column = options[:column]
    @query = options[:query]
    @association = options[:association]
  end

  def to_query
    query.present? ? query.call(operator:, value:) : column.public_send(operator_method, filter_value)
  end

  def associations
    return [] if association.blank?

    [ association ]
  end

  private

  # NOTE: cast from user input operator to arel attribute's predications
  # https://www.rubydoc.info/gems/arel/Arel/Predications
  def operator_method
    case operator
    when :eq, :not_eq, :gt, :gteq, :lt, :lteq, :between, :in, :not_in then operator
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
    when :contains, :not_contains then Arel::Nodes::Quoted.new("%#{value}%")
    when :starts_with then Arel::Nodes::Quoted.new("#{value}%")
    when :between then Range.new(value[0], value[1])
    else value
    end
  end
end
