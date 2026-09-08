module FieldDefinitions
  TargetAreaFields = Collection.new(
    [
      Field.new(
        name: :iso_region_code,
        category: :geocode,
        schema: FilterSchema::ArrayType.define,
        administrative_level: 1,
        description: "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the target area"
      ),
      Field.new(
        name: :administrative_division_level_2_code,
        category: :geocode,
        schema: FilterSchema::ArrayType.define,
        administrative_level: 2,
        description: "The second-level administrative subdivision code of the target area (e.g. district code)"
      ),
      Field.new(
        name: :administrative_division_level_3_code,
        category: :geocode,
        schema: FilterSchema::ArrayType.define,
        administrative_level: 3,
        description: "The third-level administrative subdivision code of the target area (e.g. township code)"
      ),
      Field.new(
        name: :administrative_division_level_4_code,
        category: :geocode,
        schema: FilterSchema::ArrayType.define,
        administrative_level: 4,
        description: "The fourth-level administrative subdivision code of the target area (e.g. town code)"
      ),
      Field.new(
        name: :administrative_division_level_5_code,
        category: :geocode,
        schema: FilterSchema::ArrayType.define,
        administrative_level: 5,
        description: "The fifth-level administrative subdivision code of the target area (e.g. village code)"
      )
    ]
  )
end
