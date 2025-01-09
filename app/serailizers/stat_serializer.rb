class StatSerializer < JSONAPISerializer
  attribute :result do |object|
    result = {}

    object.groups.each_with_index do |group, index|
      group_value = Array(object.key)[index]

      # NOTE: Handle field value object. Eg. enumerize field.
      group_value = group_value.value if group_value.respond_to?(:value)

      result[group] = group_value
    end

    result[:value] = object.value
    result
  end
end
