class BeneficiaryAddress < ApplicationRecord
  belongs_to :beneficiary, class_name: "Contact"
end
