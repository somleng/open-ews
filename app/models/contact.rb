class Contact < ApplicationRecord
  extend Enumerize

  COUNTRY_CODES = ISO3166::Country.codes.freeze

  include MsisdnHelpers
  include MetadataHelpers

  enumerize :status, in: [ :active, :disabled ], scope: true
  enumerize :gender, in: { male: "M", female: "F" }, scope: true
  enumerize :iso_country_code, in: COUNTRY_CODES, scope: true

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

  before_create :assign_iso_country_code, unless: :iso_country_code?

  def self.jsonapi_serializer_class
    BeneficiarySerializer
  end

  private

  def assign_iso_country_code
    self.iso_country_code = PhonyRails.country_from_number(msisdn)
  end
end
