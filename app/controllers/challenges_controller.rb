require "yaml"

class ChallengesController < ApplicationController
  THEMES_CONFIG = YAML.load_file(Rails.root.join("config", "challenge_themes.yml")).freeze

  def preview
    @theme_config = find_theme_config(params[:theme])
    @challenge = Challenge.new(
      theme: @theme_config["theme"],
      focus: @theme_config["focus"],
      tip: @theme_config["tip"],
      example_image_url: @theme_config["example_image_url"],
      date: Date.current
    )
    render :today
  end

  def today
    @challenge = Challenge.find_by!(date: Date.current)

    if @challenge.poses.empty?
      theme_config = find_theme_config(@challenge.theme)
      stages = build_stages(theme_config)
      position = 1

      if theme_config["no_image"]
        stages.each do |stage|
          stage[:count].times do
            @challenge.poses.create!(image_url: nil, duration_seconds: stage[:duration], position: position)
            position += 1
          end
        end
      else
        total_count = stages.sum { |s| s[:count] }
        image_theme = theme_config["image_theme"] || @challenge.theme
        filter_tags = theme_config["filter_tags"]
        pool_themes = THEMES_CONFIG["challenges"].select do |c|
          (c["image_theme"] || c["theme"]) == image_theme && c["filter_tags"] == filter_tags
        end.map { |c| c["theme"] }
        picker = DailyPicker.new(theme: image_theme, pool_themes: pool_themes, date: @challenge.date, poses_count: total_count, filter_tags: filter_tags)
        urls = picker.poses

        stages.each do |stage|
          stage[:count].times do
            @challenge.poses.create!(image_url: urls[position - 1], duration_seconds: stage[:duration], position: position)
            position += 1
          end
        end
      end
    end

    session[:challenge_id] = @challenge.id
    @theme_config = find_theme_config(@challenge.theme)
  end

  private

  def find_theme_config(theme)
    THEMES_CONFIG["challenges"].find { |t| t["theme"] == theme } || THEMES_CONFIG["challenges"].first
  end

  def build_stages(config)
    if config["stages"]
      config["stages"].map { |s| { count: s["count"], duration: s["duration_seconds"] } }
    else
      [ { count: config["poses_count"], duration: config["duration_seconds"] } ]
    end
  end
end
