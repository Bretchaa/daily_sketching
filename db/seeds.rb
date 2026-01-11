# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.

# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Challenge.find_or_create_by!(date: Date.current) do |c|
  c.theme = "gesture"
  c.focus = "Capture the movement, not the details."
  c.tip = "Start with one continuous line. Keep it loose."
  c.example_image_url = "/examples/gesture/example_01.png"
end

load Rails.root.join("db/seeds/challenges.rb")
