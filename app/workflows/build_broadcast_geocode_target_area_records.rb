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
      target_administrative_level = area.levels.last
      add_target_area(
        result,
        administrative_level: target_administrative_level.level,
        geocode: target_administrative_level.geocode
      )

      subdivisions_of(area).each do |locality|
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

  def subdivisions_of(target_area)
    target_path = target_area.levels.map(&:geocode)

    locality_data.select do |locality|
      locality.path.size > target_path.size && locality.path.join(".").start_with?(target_path.join("."))
    end
  end
end
