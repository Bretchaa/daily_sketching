class Cheer < ApplicationRecord
  MAX_PER_USER = 10

  belongs_to :user
  belongs_to :submission

  validates :count, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PER_USER }
end
