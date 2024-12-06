class ContactSerializer < ResourceSerializer
  attributes :msisdn, :language_code, :date_of_birth, :metadata

  attribute :gender do |object|
    object.gender_value
  end
end
