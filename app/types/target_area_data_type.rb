class TargetAreaDataType < ActiveRecord::Type::Json
  TargetAreas = Data.define(:geocode_areas, :value) do
    def self.blank
      new(geocode_areas: [], value: {})
    end
  end
  AdministrativeArea = Data.define(:levels)
  AdministrativeLevel = Data.define(:field_name, :geocode, :level)

  attr_reader :field_definitions

  def initialize(**options)
    super()
    @field_definitions = options.fetch(:field_definitions) { FieldDefinitions::TargetAreaFields }
  end

  def cast(value)
    return TargetAreas.blank if value.blank?
    return value if value.is_a?(TargetAreas)

    geocode_areas = geocoded_areas(value).map do |area|
      levels = area.map do |field_name, value|
        field_definition = field_definitions.find_by!(name: field_name)
        AdministrativeLevel.new(
          field_name:,
          geocode: value,
          level: field_definition.attributes.fetch(:administrative_level)
        )
      end
      AdministrativeArea.new(levels: levels.sort_by(&:level))
    end

    TargetAreas.new(geocode_areas:, value:)
  end

  def serialize(value)
    super(cast(value).value)
  end

  def deserialize(value)
    cast(super)
  end

  private

  def geocoded_areas(value)
    Array(value.with_indifferent_access[:geocode])
  end
end
