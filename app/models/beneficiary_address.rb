class BeneficiaryAddress < ApplicationRecord
  extend Enumerize

  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze

  belongs_to :beneficiary, class_name: "Contact"

  validates :iso_region_code,
    :administrative_division_level_2_code,
    :administrative_division_level_2_name,
    :administrative_division_level_3_code,
    :administrative_division_level_3_name,
    :administrative_division_level_4_code,
    :administrative_division_level_4_name,
    length: { maximum: 255 }
end
