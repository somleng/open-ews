class BeneficiaryAddress < ApplicationRecord
  belongs_to :account
  belongs_to :beneficiary, class_name: "Contact"
end
