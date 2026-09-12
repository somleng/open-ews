class GeocodeTargetAreaDataType < ActiveRecord::Type::Json
  GeocodeTargetAreas = Data.define(:collection, :value) do
    def self.blank
      new(collection: [], value: [])
    end
  end

  AdministrativeArea = Data.define(:hierarchy) do
    def path
      hierarchy.map(&:geocode)
    end

    def level
      path.size
    end

    def division
      hierarchy.last
    end
  end

  AdministrativeDivision = Data.define(:field_name, :geocode, :level)

  def cast(value)
    return GeocodeTargetAreas.blank if value.blank?
    return value if value.is_a?(GeocodeTargetAreas)

    collection = Array(value).map do |area|
      hierarchy = area.map do |field_name, value|
        AdministrativeDivision.new(
          field_name:,
          geocode: value,
          level: administrative_level_for(field_name)
        )
      end
      AdministrativeArea.new(hierarchy: hierarchy.sort_by(&:level))
    end

    GeocodeTargetAreas.new(collection:, value:)
  end

  def serialize(value)
    super(cast(value).value)
  end

  def deserialize(value)
    cast(super)
  end

  private

  def administrative_level_for(field_name)
    FieldDefinitions::GeocodeFieldMap.to_administrative_level(field_name)
  end
end
