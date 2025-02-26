module FieldDefinitions
  class Field
    def initialize(name:, column:, schema:, relation: nil, description: nil)
      @name = name
      @column = column
      @schema = schema
      @relation = relation
      @description = description
    end


    attr_reader :name, :column, :schema, :relation, :description
  end

  def column_name
    "#{column.relation.name}.#{column.name}"
  end
end
