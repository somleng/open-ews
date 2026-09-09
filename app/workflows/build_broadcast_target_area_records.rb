class BuildBroadcastTargetAreaRecords < ApplicationWorkflow
  AdministrativeLevel = Data.define(:level, :geocode)

  attr_reader :broadcast, :bucket, :client

  def initialize(broadcast)
    super()
    @broadcast = broadcast
  end

  def call
    broadcast.target_area_data.geocode_areas.each_with_object({}) do |area, result|
      add_target_area(result, area.levels.last)

      subdivisions_of(area.levels.map(&:geocode)).each do |administrative_level|
        add_target_area(result, administrative_level)
      end
    end.values
  end

  private

  def add_target_area(collection, administrative_level)
    collection[[ administrative_level.level, administrative_level.geocode ]] = {
      administrative_level: administrative_level.level,
      geocode: administrative_level.geocode,
      broadcast_id: broadcast.id
    }
  end

  def locality_data
    CountryAddressData.address_data(broadcast.account.iso_country_code).localities
  end

  def subdivisions_of(path)
    target = find_locality_by_path(locality_data, path)

    return [] if target.blank?

    flatten_subdivisions(target.subdivisions).map do
      AdministrativeLevel.new(level: it.path.size, geocode: it.value)
    end
  end

  def find_locality_by_path(localities, path)
    localities.each do |locality|
      return locality if locality.path == path

      result = find_locality_by_path(locality.subdivisions, path)
      return result if result.present?
    end

    nil
  end

  def flatten_subdivisions(subdivisions)
    subdivisions.flat_map do |subdivision|
      Array(subdivision).concat(flatten_subdivisions(subdivision.subdivisions))
    end
  end
end
