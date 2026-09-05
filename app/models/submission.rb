class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  validates :challenge_id, uniqueness: { scope: :user_id }
  has_one_attached :image do |attachable|
    attachable.variant :compressed, resize_to_limit: [1200, 1600], format: :jpeg, saver: { quality: 82 }
  end
  has_many :cheers, dependent: :destroy

  def total_cheers
    cheers.sum(:count)
  end
end
