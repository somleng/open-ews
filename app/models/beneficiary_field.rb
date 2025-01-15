class BeneficiaryField
  def initialize(name:, column:, relation: nil)
    @name = name
    @column = column
    @relation = relation
  end


  attr_reader :name, :column, :relation

  def self.all
    @all ||= [
      self.new(name: "status", column: "status"),
      self.new(name: "gender", column: "gender"),
      self.new(name: "disability_status", column: "disability_status"),
      self.new(name: "date_of_birth", column: "date_of_birth"),
      self.new(name: "language_code", column: "language_code"),
      self.new(name: "iso_country_code", column: "iso_country_code"),
      self.new(name: "address.iso_region_code", column: "beneficiary_addresses.iso_region_code", relation: :addresses),
      self.new(name: "address.administrative_division_level_2_code", column: "beneficiary_addresses.administrative_division_level_2_code", relation: :addresses),
      self.new(name: "address.administrative_division_level_2_name", column: "beneficiary_addresses.administrative_division_level_2_name", relation: :addresses),
      self.new(name: "address.administrative_division_level_3_code", column: "beneficiary_addresses.administrative_division_level_3_code", relation: :addresses),
      self.new(name: "address.administrative_division_level_3_name", column: "beneficiary_addresses.administrative_division_level_3_name", relation: :addresses),
      self.new(name: "address.administrative_division_level_4_code", column: "beneficiary_addresses.administrative_division_level_4_code", relation: :addresses),
      self.new(name: "address.administrative_division_level_4_name", column: "beneficiary_addresses.administrative_division_level_4_name", relation: :addresses)
    ]
  end

  def self.find(name)
    result = all.find { |f| f.name == name }
    raise ArgumentError, "Unknown field #{name}" if result.nil?
    result
  end
end
