module FieldDefinitions
  class Field
    def initialize(name:, column:, schema:, association: nil, description: nil)
      @name = name
      @column = column
      @schema = schema
      @association = association
      @description = description
    end


    attr_reader :name, :column, :schema, :association, :description
  end

  def column_name
    "#{column.relation.name}.#{column.name}"
  end
end
