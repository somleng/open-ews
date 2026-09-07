class BroadcastTargetArea < ApplicationRecord
  belongs_to :broadcast

  def self.outside(administrative_division)
    where.not(administrative_division)
  end
end
