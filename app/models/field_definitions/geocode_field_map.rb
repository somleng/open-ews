module FieldDefinitions
  class GeocodeFieldMap
    class << self
      def to_administrative_level(name)
        map.fetch(:administrative_levels).fetch(name.to_sym)
      end

      def to_name(level)
        map.fetch(:field_names).fetch(level)
      end

      private

      def map
        @map ||= begin
          data = Hash.new { |h, key| h[key] = {} }

          field_definitions.each do |field|
            administrative_level = field.metadata[:administrative_level]
            next if administrative_level.blank?

            data[:administrative_levels][field.name.to_sym] = administrative_level
            data[:field_names][administrative_level] = field.name
          end

          data
        end
      end

      def field_definitions
        BroadcastFields
      end
    end
  end
end
