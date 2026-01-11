class Pose < ApplicationRecord
  belongs_to :challenge

  validates :image_url, :duration_seconds, :position, presence: true
end
