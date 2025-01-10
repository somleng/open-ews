class BeneficiarySerializer < ResourceSerializer
  attributes :phone_number, :gender, :language_code, :date_of_birth, :iso_country_code, :metadata
  has_many :addresses, serializer: BeneficiaryAddressSerializer

  attribute :phone_number do |object|
    object.msisdn
  end
end
