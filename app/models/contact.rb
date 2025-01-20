class Contact < ApplicationRecord
  extend Enumerize

  include MetadataHelpers

  attribute :msisdn, :phone_number

  enumerize :status, in: [ :active, :disabled ], scope: :shallow
  enumerize :gender, in: [ "M", "F" ]
  enumerize :disability_status, in: [ :normal, :disabled ]
  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze

  belongs_to :account

  has_many :addresses, class_name: "BeneficiaryAddress", foreign_key: :beneficiary_id
  has_many :callout_participations
  has_many :callouts, through: :callout_participations
  has_many :phone_calls
  has_many :remote_phone_call_events, through: :phone_calls

  validates :msisdn, presence: true

  delegate :call_flow_logic,
           to: :account,
           allow_nil: true

  def self.jsonapi_serializer_class
    BeneficiarySerializer
  end
end
