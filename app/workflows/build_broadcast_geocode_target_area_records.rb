class BuildBroadcastGeocodeTargetAreaRecords < ApplicationWorkflow
  AdministrativeLevel = Data.define(:level, :geocode)

  attr_reader :broadcast, :locality_data

  def initialize(broadcast, **options)
    super()
    @broadcast = broadcast
    @locality_data = options.fetch(:locality_data) do
      CountryAddressData.address_data(broadcast.account.iso_country_code).collection
    end
  end

  def call
    geocode_areas = broadcast.target_areas.geocode.each_with_object({}) do |area, result|
      add_target_area(
        result,
        administrative_level: area.level,
        geocode: area.division.geocode
      )

      locality_data.subdivisions_of(area.path).each do |locality|
        add_target_area(
          result,
          administrative_level: locality.administrative_level,
          geocode: locality.value
        )
      end
    end
    geocode_areas.values
  end

  private

  def add_target_area(collection, administrative_level:, geocode:)
    collection[[ administrative_level, geocode ]] = {
      administrative_level:,
      geocode:,
      broadcast_id: broadcast.id
    }
  end
end
