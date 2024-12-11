class ContactSerializer < ResourceSerializer
  attributes :msisdn, :language_code, :date_of_birth, :iso_country_code, :metadata
  has_many :addresses, serializer: BeneficiaryAddressSerializer

  attribute :gender do |object|
    object.gender_value
  end
end
