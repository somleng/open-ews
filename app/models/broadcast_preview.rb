class BroadcastPreview
  attr_reader :broadcast

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def filtered_beneficiaries
    beneficiary_filter_group = beneficiary_filter.output
    beneficiary_address_filter_group = target_areas.filter_group

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

  def target_areas
    @target_areas ||= begin
      target_areas = TargetAreaDataType.new(include: :filter_group).cast(broadcast.target_area_data)
      modify_target_area_conditions(target_areas.filter_group.conditions)
      target_areas
    end
  end

  def modify_target_area_conditions(conditions)
    conditions.each do |condition|
      if condition.type.field?
        condition.column = BeneficiaryAddress.arel_table[condition.name]
        condition.association = :addresses
      else
        modify_target_area_conditions(condition.conditions)
      end
    end
  end
end
