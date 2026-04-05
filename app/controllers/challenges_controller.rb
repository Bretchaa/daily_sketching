require "yaml"

class ChallengesController < ApplicationController
  THEMES_CONFIG = YAML.load_file(Rails.root.join("config", "challenge_themes.yml")).freeze

  def today
    @challenge = Challenge.find_by!(date: Date.current)

    if @challenge.poses.empty?
      theme_config    = find_theme_config(@challenge.theme)
      poses_count     = theme_config["poses_count"]
      duration        = theme_config["duration_seconds"]
      warmup_count    = theme_config["warmup_count"] || 0
      warmup_duration = theme_config["warmup_duration_seconds"] || duration

      total_count = warmup_count + poses_count
      picker = DailyPicker.new(theme: @challenge.theme, date: @challenge.date, poses_count: total_count)
      urls = picker.poses

      position = 1
      warmup_count.times do |i|
        @challenge.poses.create!(image_url: urls[i], duration_seconds: warmup_duration, position: position)
        position += 1
      end
      poses_count.times do |i|
        @challenge.poses.create!(image_url: urls[warmup_count + i], duration_seconds: duration, position: position)
        position += 1
      end
    end

    session[:challenge_id] = @challenge.id
    @theme_config = find_theme_config(@challenge.theme)
  end

  private

  def find_theme_config(theme)
    all = THEMES_CONFIG["weekday_rotation"] + [ THEMES_CONFIG["weekend"] ]
    all.find { |t| t["theme"] == theme } || THEMES_CONFIG["weekday_rotation"].first
  end
end
