# db/seeds/challenges.rb

challenges = [
  {
    date: Date.current,
    theme: "gesture",
    focus: "Capture the movement and overall energy of the pose. Do not worry about details.",
    tip: "Use long, continuous lines. Draw fast and loose."
  },
  {
    date: Date.current + 1.day,
    theme: "portrait",
    focus: "Focus on big shapes and proportions before details.",
    tip: "Block in the head shape first. Add features last."
  },
  {
    date: Date.current + 2.days,
    theme: "long_poses",
    focus: "Take your time and observe carefully before drawing.",
    tip: "Spend the first minute just looking at the pose."
  }
]

challenges.each do |attrs|
  Challenge.find_or_create_by!(date: attrs[:date]) do |c|
    c.theme = attrs[:theme]
    c.focus = attrs[:focus]
    c.tip = attrs[:tip]
    c.example_image_url = nil
  end
end

puts "✅ Seeded #{challenges.size} challenges"

