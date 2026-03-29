require "yaml"

namespace :challenges do
  desc "Generate challenges for the next N days (default 7). Usage: rails challenges:generate or rails 'challenges:generate[14]'"
  task :generate, [ :days ] => :environment do |_, args|
    days = (args[:days] || 7).to_i
    config = YAML.load_file(Rails.root.join("config", "challenge_themes.yml"))
    rotation = config["weekday_rotation"]
    weekend  = config["weekend"]
    manifest = JSON.parse(File.read(Rails.root.join("config", "image_manifest.json")))

    # Find which rotation index to start from by counting existing weekday challenges
    weekday_count = Challenge.where("date < ?", Date.current)
                             .where("STRFTIME('%w', date) NOT IN ('0', '6')")
                             .count

    created = 0
    skipped = 0

    (0...days).each do |offset|
      date = Date.current + offset
      next if Challenge.exists?(date: date)

      if date.saturday? || date.sunday?
        attrs = weekend
      else
        attrs = rotation[weekday_count % rotation.size]
        weekday_count += 1
      end

      # Fall back to gesture if theme has no images yet
      theme = attrs["theme"]
      unless (manifest.dig(theme, "poses") || []).any?
        theme = "gesture"
      end

      Challenge.create!(
        date: date,
        theme: theme,
        focus: attrs["focus"],
        tip: attrs["tip"]
      )
      created += 1
      puts "✅ #{date} (#{date.strftime('%A')}) — #{attrs['display_name']}"
    end

    puts "\nDone. #{created} challenge(s) created, #{skipped} skipped."
  end
end
