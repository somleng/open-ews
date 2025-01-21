class StatSerializer < JSONAPISerializer
  attribute :result do |object|
    result = {}

    object.groups.each_with_index do |group, index|
      result[group] = object.key[index]
    end

    result[:value] = object.value
    result
  end
end
