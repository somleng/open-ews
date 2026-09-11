module CountryAddressData
  class Collection
    include Enumerable

    attr_accessor :data

    delegate :each, to: :items

    def initialize
      @data = {}
    end

    def add(item)
      data[item.path] = item
    end

    def to_tree
      data.values.each_with_object([]) do |locality, tree|
        parent_path = locality.path[0...-1]

        if parent_path.blank?
          tree << locality
        else
          parent_node = data.fetch(parent_path)
          parent_node.subdivisions << locality
        end
      end
    end

    private

    def items
      data.values
    end
  end
end
