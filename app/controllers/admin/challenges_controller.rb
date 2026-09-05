class Admin::ChallengesController < Admin::BaseController
  THEMES_CONFIG = YAML.load_file(Rails.root.join("config", "challenge_themes.yml")).freeze

  def index
    @upcoming     = Challenge.where(date: Date.current..).order(:date).limit(60)
    @theme_configs = THEMES_CONFIG["challenges"]
  end
end
