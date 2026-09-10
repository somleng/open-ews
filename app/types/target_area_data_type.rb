class TargetAreaDataType < ActiveRecord::Type::Json
  TargetAreas = Data.define(:geocode, :value) do
    def self.blank
      new(geocode: [], value: {})
    end
  end
  AdministrativeArea = Data.define(:levels)
  AdministrativeLevel = Data.define(:field_name, :geocode, :level)

  attr_reader :field_definitions

  def initialize(**options)
    super()
    @field_definitions = options.fetch(:field_definitions)
  end

  def cast(value)
    return TargetAreas.blank if value.blank?
    return value if value.is_a?(TargetAreas)

    geocode_areas = Array(value.with_indifferent_access[:geocode]).map do |area|
      levels = area.map do |field_name, value|
        AdministrativeLevel.new(
          field_name:,
          geocode: value,
          level: administrative_level_for(field_name)
        )
      end
      AdministrativeArea.new(levels: levels.sort_by(&:level))
    end

    TargetAreas.new(geocode: geocode_areas, value:)
  end

  def serialize(value)
    super(cast(value).value)
  end

  def deserialize(value)
    cast(super)
  end

  private

  def administrative_level_for(field_name)
    result = field_definitions.respond_to?(:call) ? field_definitions.call : field_definitions
    result.find_by!(name: field_name).attributes.fetch(:administrative_level)
  end
end
