module CountryLocalityData
  class Collection
    include Enumerable

    attr_accessor :data

    delegate :each, to: :items
    delegate :fetch, to: :data

    def initialize
      @data = {}
    end

    def add(item)
      data[item.path] = item
    end

    def subdivisions_of(path)
      items.select { it.path.size > path.size && it.path.join(".").start_with?(path.join(".")) }
    end

    private

    def items
      data.values
    end
  end
end
