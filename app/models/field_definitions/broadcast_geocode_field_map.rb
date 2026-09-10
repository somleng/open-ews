module FieldDefinitions
  class BroadcastGeocodeFieldMap
    def self.to_administrative_level(name)
      BroadcastFields.find_by!(name:).metadata.fetch(:administrative_level)
    end

    def self.to_name(level)
      BroadcastFields.find_by!([ :metadata, :administrative_level ] => level).name
    end
  end
end
