module FieldDefinitions
  class Field
    attr_reader :name, :column, :schema, :association, :description, :attributes

    def initialize(attributes)
      @name = attributes.fetch(:name)
      @column = attributes.fetch(:column)
      @schema = attributes.fetch(:schema)
      @association = attributes[:association]
      @description = attributes[:description]
      @attributes = attributes
    end

    def clone(overrides)
      self.class.new(attributes.merge(overrides))
    end
  end
end
