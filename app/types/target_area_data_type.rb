class TargetAreaDataType < ActiveRecord::Type::Json
  TargetAreas = Data.define(:geocode, :value) do
    def self.blank
      new(geocode: [], value: {})
    end
  end

  def cast(value)
    return TargetAreas.blank if value.blank?
    return value if value.is_a?(TargetAreas)

    geocode = cast_geocode(value.with_indifferent_access[:geocode]).collection
    TargetAreas.new(geocode:, value:)
  end

  def serialize(value)
    super(cast(value).value)
  end

  def deserialize(value)
    cast(super)
  end

  private

  def cast_geocode(value)
    GeocodeTargetAreaDataType.new.cast(value)
  end
end
