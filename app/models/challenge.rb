class Challenge < ApplicationRecord
  has_many :poses, -> { order(:position) }, dependent: :destroy

  validates :date, presence: true, uniqueness: true
  validates :theme, presence: true
end