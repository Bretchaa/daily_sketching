require "yaml"

class ChallengesController < ApplicationController
  THEMES_CONFIG = YAML.load_file(Rails.root.join("config", "challenge_themes.yml")).freeze

  def today
    @challenge = Challenge.find_by!(date: Date.current)

    if @challenge.poses.empty?
      theme_config = find_theme_config(@challenge.theme)
      stages = build_stages(theme_config)

      total_count = stages.sum { |s| s[:count] }
      picker = DailyPicker.new(theme: @challenge.theme, date: @challenge.date, poses_count: total_count)
      urls = picker.poses

      position = 1
      stages.each do |stage|
        stage[:count].times do
          @challenge.poses.create!(image_url: urls[position - 1], duration_seconds: stage[:duration], position: position)
          position += 1
        end
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

  def build_stages(config)
    if config["stages"]
      config["stages"].map { |s| { count: s["count"], duration: s["duration_seconds"] } }
    else
      [ { count: config["poses_count"], duration: config["duration_seconds"] } ]
    end
  end
end
