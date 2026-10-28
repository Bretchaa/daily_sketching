class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  validates :challenge_id, uniqueness: { scope: :user_id }
  has_one_attached :image do |attachable|
    attachable.variant :compressed, resize_to_limit: [ 1200, 1600 ], format: :jpeg, saver: { quality: 82 }
  end
  has_many :cheers, dependent: :destroy

  def total_cheers
    cheers.sum(:count)
  end

  # "width / height" for CSS aspect-ratio, or nil if the upload was never measured
  def image_aspect_ratio
    meta = image.blob.metadata
    "#{meta["width"]} / #{meta["height"]}" if meta["width"].to_i > 0 && meta["height"].to_i > 0
  end
end
