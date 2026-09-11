module CountryLocalityData
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

    def subdivisions_of(path)
      items.select { it.path.size > path.size && it.path.join(".").start_with?(path.join(".")) }
    end

    def to_tree(&block)
      nodes_by_path = {}

      items.sort_by { it.path.size }.each_with_object([]) do |locality, tree|
        node_data = yield(locality)
        nodes_by_path[locality.path] = node_data

        parent_node = nodes_by_path[locality.path[0...-1]]

        if parent_node.present?
          parent_node.fetch(:children) << node_data
        else
          tree << node_data
        end
      end
    end

    private

    def items
      data.values
    end
  end
end
