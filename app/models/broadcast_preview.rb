class BroadcastPreview
  attr_reader :broadcast

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def filtered_beneficiaries
    beneficiary_filter_group = beneficiary_filter.output
    beneficiary_address_filter_group = build_beneficiary_address_filter_group

    return Beneficiary.none if beneficiary_filter_group.blank? && beneficiary_address_filter_group.blank?

    FilterScopeQuery.new(
      scope: broadcast.account.beneficiaries.active.where.not(id: group_beneficiaries.select(:id)),
      filter_group: FilterGroup.new(
        conditions: [ beneficiary_filter_group, beneficiary_address_filter_group ]
      )
    ).apply
  end

  def group_beneficiaries
    broadcast.group_beneficiaries.active
  end

  def beneficiaries
    Beneficiary.where(id: filtered_beneficiaries.select(:id)).or(Beneficiary.where(id: group_beneficiaries.select(:id))).distinct
  end

  private

  def beneficiary_filter
    @beneficiary_filter ||= BeneficiaryFilter.new(input_params: broadcast.beneficiary_filter)
  end

  def build_beneficiary_address_filter_group
    area_groups = broadcast.target_areas.geocode.map do |area|
      fields = area.levels.map do |level|
        FilterField.new(
          name: level.field_name,
          operator: :eq,
          value: level.geocode,
          column: BeneficiaryAddress.arel_table[level.field_name],
          association: :addresses
        )
      end
      FilterGroup.new(conditions: fields, conjunction: :and)
    end

    FilterGroup.new(conditions: area_groups, conjunction: :or)
  end
end
