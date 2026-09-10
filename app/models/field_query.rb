FieldQuery = Data.define(:association, :arel_column) do
  def initialize(**)
    super(association: nil, arel_column: nil, **)
  end
end
