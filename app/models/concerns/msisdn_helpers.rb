module MsisdnHelpers
  extend ActiveSupport::Concern

  NUMBER_FORMAT = /\A\d+\z/

  included do
    validates :msisdn, presence: true, format: { with: NUMBER_FORMAT }
  end
end
