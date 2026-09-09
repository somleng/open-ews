class TargetAreaDataType < ActiveRecord::Type::String
  TargetAreas = Data.define(:data, :filter_group, :target_area_records) do
    def self.blank
      new(data: {}, filter_group: FilterGroup.new, target_area_records: [])
    end
  end

  AdministrativeLevel = Data.define(:administrative_level, :geocode)

  attr_reader :options

  def initialize(include: [], **)
    include = [ include ] if include.is_a?(Hash)

    @options = Array(include).each_with_object({}) do |element, hash|
      case element
      when Hash
        hash.merge!(element)
      when Symbol, String
        hash[element.to_sym] = {}
      end
    end

    super(**)
  end

  def cast(value)
    return TargetAreas.blank if value.blank?
    return value if value.is_a?(TargetAreas)

    data = value
    filter_group = FilterGroup.new
    target_area_records = []

    filter_group = build_filter_group(value) if build_filter_group?
    target_area_records = build_target_area_records(value) if build_target_area_records?

    TargetAreas.new(data:, filter_group:, target_area_records:)
  end

  private

  def build_filter_group?
    options.key?(:filter_group)
  end

  def build_target_area_records?
    options.key?(:target_area_records)
  end

  def build_filter_group(value)
    area_groups = geocoded_areas(value).map do |area|
      fields = area.map do |field_name, value|
        FilterField.new(name: field_name, operator: :eq, value:)
      end
      FilterGroup.new(conditions: fields, conjunction: :and)
    end

    FilterGroup.new(conditions: area_groups, conjunction: :or)
  end

  def build_target_area_records(value)
    geocoded_areas(value).each_with_object({}) do |area, result|
      administrative_levels = build_administrative_levels(area)
      add_target_area(result, administrative_levels.last)

      subdivisions_of(administrative_levels.map(&:geocode)).each do |administrative_division|
        add_target_area(result, administrative_division)
      end
    end.values
  end

  def build_administrative_levels(area)
    area.values.map.with_index(1) do |geocode, index|
      AdministrativeLevel.new(administrative_level: index, geocode:)
    end
  end

  def add_target_area(collection, administrative_level)
    collection[[ administrative_level.administrative_level, administrative_level.geocode ]] = {
      administrative_level: administrative_level.administrative_level,
      geocode: administrative_level.geocode
    }
  end

  def locality_data
    Array(options.dig(:target_area_records, :locality_data))
  end

  def subdivisions_of(path)
    target = find_locality_by_path(locality_data, path)

    return [] if target.blank?

    flatten_subdivisions(target.subdivisions).map do
      AdministrativeLevel.new(administrative_level: it.path.size, geocode: it.value)
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

  def geocoded_areas(value)
    Array(value.with_indifferent_access[:geocode])
  end
end
