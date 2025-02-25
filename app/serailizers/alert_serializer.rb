class AlertSerializer < ResourceSerializer
  attributes :phone_number, :status

  belongs_to :broadcast
  belongs_to :beneficiary
end
