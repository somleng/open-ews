module FieldDefinitions
  class Field
    attr_reader :name, :column, :schema, :association, :description

    def initialize(name:, column:, schema:, association: nil, description: nil)
      @name = name
      @column = column
      @schema = schema
      @association = association
      @description = description
    end
  end
end
