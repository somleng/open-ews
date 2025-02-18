class SimpleColumnField
  def initialize(name:, column:, relation: nil, description: nil)
    @name = name
    @column = column
    @relation = relation
    @description = description
  end


  attr_reader :name, :column, :relation, :description
end
