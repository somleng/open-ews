class BeneficiarySerializer < ResourceSerializer
  attributes :phone_number, :gender, :disability_status, :language_code, :date_of_birth, :iso_country_code, :metadata
  has_many :addresses, serializer: BeneficiaryAddressSerializer
end
