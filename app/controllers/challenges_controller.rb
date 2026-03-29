require "yaml"

class ChallengesController < ApplicationController
  THEMES_CONFIG = YAML.load_file(Rails.root.join("config", "challenge_themes.yml")).freeze

  def today
    @challenge = Challenge.find_by!(date: Date.current)

    if @challenge.poses.empty?
      theme_config = find_theme_config(@challenge.theme)
      poses_count = theme_config["poses_count"]
      duration    = theme_config["duration_seconds"]

      picker = DailyPicker.new(theme: @challenge.theme, date: @challenge.date, poses_count: poses_count)
      picker.poses.each_with_index do |url, idx|
        @challenge.poses.create!(
          image_url: url,
          duration_seconds: duration,
          position: idx + 1
        )
      end
    end

    session[:challenge_id] = @challenge.id
  end

  private

  def find_theme_config(theme)
    all = THEMES_CONFIG["weekday_rotation"] + [ THEMES_CONFIG["weekend"] ]
    all.find { |t| t["theme"] == theme } || THEMES_CONFIG["weekday_rotation"].first
  end
end
