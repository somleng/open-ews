module CountryAddressData
  Locality = Data.define(:value, :path, :name_en, :name_local, :subdivisions) do
    def administrative_level
      path.size
    end
  end
end
