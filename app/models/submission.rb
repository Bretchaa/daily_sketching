class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  has_one_attached :image
end
