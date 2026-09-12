class BuildGeocodeTargetAreaRecords < ApplicationWorkflow
  attr_reader :target_areas, :locality_data

  def initialize(target_areas, locality_data:)
    super()
    @target_areas = target_areas
    @locality_data = locality_data
  end

  def call
    geocode_areas = target_areas.each_with_object({}) do |area, result|
      add_target_area(
        result,
        path: area.path,
        geocode: area.division.geocode
      )

      locality_data.subdivisions_of(area.path).each do |locality|
        add_target_area(
          result,
          path: locality.path,
          geocode: locality.value
        )
      end
    end
    geocode_areas.values
  end

  private

  def add_target_area(collection, path:, geocode:)
    collection[[ path ]] = { path:, administrative_level: path.size, geocode: }
  end
end
