require "yaml"
require "zlib"

namespace :challenges do
  desc "Generate daily challenges for the next N days (default: 30). Usage: rails challenges:generate[60]"
  task :generate, [ :days ] => :environment do |_, args|
    days = (args[:days] || 30).to_i
    config = YAML.load_file(Rails.root.join("config", "challenge_themes.yml"))
    themes = config["challenges"]
    cooldowns = themes.each_with_object({}) { |t, h| h[t["theme"]] = t["cooldown_days"] || 1 }
    pool = themes.reject { |t| t["no_image"] }.flat_map { |t| Array.new(t["weight"], t["theme"]) }

    generated = 0
    skipped = 0

    # Build recent history from existing challenges
    recent_history = Challenge.where(date: (Date.current - 14)...Date.current)
                              .order(:date).pluck(:date, :theme).to_h

    (0...days).each do |offset|
      date = Date.current + offset

      if Challenge.exists?(date: date)
        existing = Challenge.find_by(date: date)
        recent_history[date] = existing.theme
        skipped += 1
        next
      end

      # Exclude themes still in their cooldown window
      on_cooldown = themes.map { |t|
        cooldown = cooldowns[t["theme"]]
        used_recently = (1..cooldown).any? { |d| recent_history[date - d] == t["theme"] }
        t["theme"] if used_recently
      }.compact

      seed = Zlib.crc32("challenge-#{date.iso8601}")
      rng = Random.new(seed)
      available_pool = pool.reject { |t| on_cooldown.include?(t) }
      available_pool = pool if available_pool.empty? # fallback if all on cooldown
      theme = available_pool.sample(random: rng)

      theme_config = themes.find { |t| t["theme"] == theme }

      Challenge.create!(
        date: date,
        theme: theme,
        focus: theme_config["focus"],
        tip: theme_config["tip"],
        example_image_url: theme_config["example_image_url"]
      )

      puts "#{date} — #{theme_config['display_name']}"
      recent_history[date] = theme
      generated += 1
    end

    puts "\nDone! #{generated} challenges created, #{skipped} already existed."
  end

  desc "Replace upcoming challenges whose theme is paused (weight 0) and hasn't started yet, then refill the schedule"
  task replace_paused: :environment do
    config = YAML.load_file(Rails.root.join("config", "challenge_themes.yml"))
    paused = config["challenges"].select { |t| t["weight"].to_i.zero? }.map { |t| t["theme"] }

    # Only days nobody has opened yet: no poses picked, no drawings uploaded
    replaceable = Challenge.where(theme: paused).where("date >= ?", Date.current)
                           .where.missing(:poses).where.missing(:submissions)
    replaceable.each { |c| puts "Removing #{c.date} — #{c.theme}" }
    replaceable.destroy_all

    Rake::Task["challenges:generate"].invoke
  end

  desc "Check that challenges exist for the next N days (default: 7). Exits with error if any are missing."
  task :validate, [ :days ] => :environment do |_, args|
    days = (args[:days] || 7).to_i
    missing = (0...days).map { |i| Date.current + i }.reject { |d| Challenge.exists?(date: d) }
    if missing.any?
      missing.each { |d| puts "MISSING challenge for #{d}" }
      abort "Schedule has gaps — run rails challenges:generate to fix."
    else
      puts "OK: challenges exist for the next #{days} days."
    end
  end

  desc "Preview the next N days of challenges without creating them. Usage: rails challenges:preview[14]"
  task :preview, [ :days ] => :environment do |_, args|
    days = (args[:days] || 14).to_i
    config = YAML.load_file(Rails.root.join("config", "challenge_themes.yml"))
    themes = config["challenges"]
    cooldowns = themes.each_with_object({}) { |t, h| h[t["theme"]] = t["cooldown_days"] || 1 }
    pool = themes.flat_map { |t| Array.new(t["weight"], t["theme"]) }

    recent_history = Challenge.where(date: (Date.current - 14)...Date.current)
                              .order(:date).pluck(:date, :theme).to_h

    (0...days).each do |offset|
      date = Date.current + offset
      existing = Challenge.find_by(date: date)

      if existing
        theme_config = themes.find { |t| t["theme"] == existing.theme }
        puts "#{date} — #{theme_config&.dig('display_name') || existing.theme} (already set)"
        recent_history[date] = existing.theme
      else
        on_cooldown = themes.map { |t|
          cooldown = cooldowns[t["theme"]]
          used_recently = (1..cooldown).any? { |d| recent_history[date - d] == t["theme"] }
          t["theme"] if used_recently
        }.compact

        seed = Zlib.crc32("challenge-#{date.iso8601}")
        rng = Random.new(seed)
        available_pool = pool.reject { |t| on_cooldown.include?(t) }
        available_pool = pool if available_pool.empty?
        theme = available_pool.sample(random: rng)
        theme_config = themes.find { |t| t["theme"] == theme }
        puts "#{date} — #{theme_config['display_name']} (pending)"
        recent_history[date] = theme
      end
    end
  end
end
