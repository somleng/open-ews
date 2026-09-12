FilterField = Data.define(:operator, :value, :query, :metadata) do
  def initialize(**)
    super(metadata: {}, **)
  end

  def to_query
    query.to_arel(operator:, value:, **metadata)
  end

  def associations
    return [] if query.association.blank?

    [ query.association ]
  end
end
