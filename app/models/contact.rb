class Contact < ApplicationRecord
  extend Enumerize

  include MsisdnHelpers
  include MetadataHelpers

  enumerize :status, in: [ :active, :disabled ], scope: :shallow
  enumerize :gender, in: { male: "M", female: "F" }
  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze

  belongs_to :account

  has_many :addresses, class_name: "BeneficiaryAddress", foreign_key: :beneficiary_id

  has_many :callout_participations,
           dependent: :restrict_with_error

  has_many :callouts,
           through: :callout_participations

  has_many :phone_calls,
           dependent: :restrict_with_error

  has_many :remote_phone_call_events,
           through: :phone_calls

  delegate :call_flow_logic,
           to: :account,
           allow_nil: true

  def self.jsonapi_serializer_class
    BeneficiarySerializer
  end
end
