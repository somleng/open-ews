class Recording < ApplicationRecord
  belongs_to :account
  belongs_to :phone_call
  belongs_to :beneficiary

  has_one_attached :audio_file
end
