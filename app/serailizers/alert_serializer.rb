class AlertSerializer < ResourceSerializer
  attributes :phone_number, :status, :delivery_attempts_count

  belongs_to :broadcast
  belongs_to :beneficiary
end
