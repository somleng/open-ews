class CreateBeneficiaryWithAddress < ApplicationWorkflow
  attr_reader :contact_params, :address_params

  def initialize(params)
    @contact_params = params.except(:address)
    @address_params = params.fetch(:address, {})
  end

  def call
    ApplicationRecord.transaction do
      contact = Contact.create!(contact_params)
      contact.addresses.create!(address_params) if address_params.present?
      contact
    end
  end
end
