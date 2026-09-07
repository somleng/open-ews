class BroadcastPreview
  attr_reader :broadcast

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def filtered_beneficiaries
    beneficiary_filter_group = beneficiary_filter.output
    target_area_filter_group = target_area_filter.output

    return Beneficiary.none if beneficiary_filter_group.blank? && target_area_filter_group.blank?

    FilterScopeQuery.new(
      scope: broadcast.account.beneficiaries.active.where.not(id: group_beneficiaries.select(:id)),
      filter_group: FilterGroup.new(
        conditions: [ beneficiary_filter_group, target_area_filter_group ]
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

  def target_area_filter
    @target_area_filter || TargetAreaFilter.new(input_params: broadcast.target_area_data)
  end
end
