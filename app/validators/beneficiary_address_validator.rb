class BeneficiaryAddressValidator
  attr_reader :attributes, :errors

  Error = Data.define(:key, :message)

  def initialize(attributes)
    @attributes = attributes
    @errors = []
  end


  def valid?
    4.downto(3) do |level|
      division_attributes = [ :code, :name ].map { |type| :"administrative_division_level_#{level}_#{type}" }

      next if division_attributes.all? { |division_attribute| attributes[division_attribute].blank? }

      parent_level = level - 1
      parent_division_attributes = [ :code, :name ].map { |type| :"administrative_division_level_#{parent_level}_#{type}" }

      next if parent_division_attributes.any? { |parent_division_attribute| attributes[parent_division_attribute].present? }

      errors << Error.new(key: parent_division_attributes.first, message: "must be present")
      return false
    end

    errors.empty?
  end
end
