module CountryAddressData
  class Cambodia
    class << self
      def address_data
        collection = Collection.new

        Pumi::Province.all.each do |province|
          locality = build_locality(province) do
            [ province.iso3166_2, [ province.iso3166_2 ] ]
          end
          collection.add(locality)
        end

        Pumi::District.all.each do |district|
          locality = build_locality(district) do
            [ district.id, [ district.province.iso3166_2, district.id ] ]
          end
          collection.add(locality)
        end

        Pumi::Commune.all.each do |commune|
          locality = build_locality(commune) do
            [ commune.id, [ commune.province.iso3166_2, commune.district.id, commune.id ] ]
          end
          collection.add(locality)
        end

        collection
      end

      private

      def build_locality(data, &)
        value, path = yield(data)
        CountryAddressData::Locality.new(
          value:,
          name_en: data.name_latin,
          name_local: data.name_km,
          path:,
          subdivisions: []
        )
      end
    end
  end
end
