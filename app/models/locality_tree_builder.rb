class LocalityTreeBuilder
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def to_tree
    data.each_with_object([]) do |locality, tree|
      parent_path = locality.path[0...-1]

      if parent_path.blank?
        tree << locality
      else
        parent_node = data.fetch(parent_path)
        parent_node.subdivisions << locality
      end
    end
  end
end
