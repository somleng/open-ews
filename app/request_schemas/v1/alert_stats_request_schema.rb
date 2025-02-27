module V1
  class AlertStatsRequestSchema < ApplicationRequestSchema
    GROUPS = [
      "status",
      "beneficiary.gender",
      "beneficiary.disability_status",
      "beneficiary.language_code",
      "beneficiary.iso_country_code",
      "address.iso_region_code",
      "beneficiary.address.administrative_division_level_2_code",
      "beneficiary.address.administrative_division_level_2_name",
      "beneficiary.address.administrative_division_level_3_code",
      "beneficiary.address.administrative_division_level_3_name",
      "beneficiary.address.administrative_division_level_4_code",
      "beneficiary.address.administrative_division_level_4_name"
    ].freeze

    params do
      optional(:filter).schema(AlertFilter.schema)
      required(:group_by).value(:array).each(:string, included_in?: GROUPS)
    end

    rule(:filter).validate(contract: AlertFilter)

    def output
      result = super

      if result[:filter]
        result[:filter_fields] = AlertFilter.new(input_params: result[:filter]).output
      end

      result[:group_by_fields] = result[:group_by].map do |group|
        FieldDefinitions::AlertFields.find(group)
      end

      result
    end
  end
end
