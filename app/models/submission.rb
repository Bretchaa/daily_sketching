class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  has_one_attached :image
  has_many :cheers, dependent: :destroy

  def total_cheers
    cheers.sum(:count)
  end
end
