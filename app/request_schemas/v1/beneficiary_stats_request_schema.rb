module V1
  class BeneficiaryStatsRequestSchema < ApplicationRequestSchema
    # Group = Data.define(:name, :column)

    # COUNTRY_GROUP = Group.new(name: "country", column: :iso_country_code)
    # REGION_GROUP = Group.new(name: "region", column: :iso_region_code)
    # LOCALITY_GROUP = Group.new(name: "locality", column: :locality)
    #
    # GROUPS = [ COUNTRY_GROUP, REGION_GROUP, LOCALITY_GROUP ].freeze
    #
    # VALID_GROUP_BY_OPTIONS = [
    #   [ COUNTRY_GROUP, REGION_GROUP, LOCALITY_GROUP ]
    # ]

    params do
      optional(:filter).value(:hash).hash do
        optional(:gender).filled(Types::UpcaseString, included_in?: Contact.gender.values)
      end
      required(:group_by).value(array[:string])
    end

    # rule(:group_by) do |context:|
    #   context[:groups] = find_groups(value)
    #   key.failure("is invalid") if context[:groups].blank?
    # end

    def output
      result = super

      # filter = params.fetch(:filter)
      # conditions = filter.slice(:type, :locality)
      # conditions[:iso_country_code] = filter.fetch(:country) if filter.key?(:country)
      # conditions[:iso_region_code] = filter.fetch(:region) if filter.key?(:region)
      #
      # result = {}
      #
      # result[:named_scopes] = :available
      # result[:conditions] = conditions
      result[:groups] = result[:group_by]
      result
    end

    private

    def find_groups(group_names)
      VALID_GROUP_BY_OPTIONS.find { |group_list| group_list.map(&:name).sort == group_names.sort }
    end
  end
end
