module FieldDefinitions
  class Collection
    include Enumerable

    attr_reader :collection

    delegate :each, to: :collection

    def initialize(collection)
      @collection = collection
    end

    def find(name)
      result = collection.find { |f| f.name == name }
      raise ArgumentError, "Unknown field #{name}" if result.nil?
      result
    end
  end
end
