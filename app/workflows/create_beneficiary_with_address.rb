class CreateBeneficiaryWithAddress < ApplicationWorkflow
  attr_reader :beneficiary_params, :address_params

  def initialize(params)
    @beneficiary_params = params.except(:address)
    @address_params = params.fetch(:address, {})
  end

  def call
    ApplicationRecord.transaction do
      beneficiary = Beneficiary.create!(beneficiary_params)
      beneficiary.addresses.create!(address_params) if address_params.present?
      beneficiary
    end
  end
end
