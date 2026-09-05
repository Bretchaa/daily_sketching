class Pose < ApplicationRecord
  belongs_to :challenge

  validates :duration_seconds, :position, presence: true
end
