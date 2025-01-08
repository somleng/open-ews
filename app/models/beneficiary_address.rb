class BeneficiaryAddress < ApplicationRecord
  extend Enumerize

  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze

  belongs_to :beneficiary, class_name: "Contact"
end
