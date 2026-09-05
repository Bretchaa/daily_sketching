require "yaml"

class HomeController < ApplicationController
  def index
    recent_challenge = (1..7).each do |days_ago|
      challenge = Challenge.find_by(date: Date.current - days_ago)
      next unless challenge
      subs = challenge.submissions.joins(:image_attachment)
      break challenge if subs.exists?
    end

    if recent_challenge.is_a?(Challenge)
      subs_scope = recent_challenge.submissions.joins(:image_attachment)
      @yesterday_count = subs_scope.count
      my_sub = current_user ? subs_scope.find_by(user: current_user) : nil
      others = subs_scope.includes(:user, :cheers)
                         .order(created_at: :desc)
                         .where.not(user: current_user)
                         .limit(my_sub ? 7 : 8)
                         .to_a
      @yesterday_submissions = ([ my_sub ] + others).compact
      @my_yesterday_submission = my_sub
      @yesterday_theme = recent_challenge.theme
      @gallery_date = recent_challenge.date
    else
      @yesterday_count = 0
      @yesterday_submissions = []
    end

    themes_config = YAML.load_file(Rails.root.join("config", "challenge_themes.yml"))
    @example_images = themes_config["challenges"]
      .select { |t| t["homepage_example"] && t["example_image_url"].present? }
      .map { |t| t["example_image_url"] }

    @streak = current_user ? current_user.streak : 0
    today_challenge = Challenge.find_by(date: Date.current)
    @drew_today = current_user && today_challenge &&
                  current_user.submissions.joins(:image_attachment).exists?(challenge: today_challenge)
    @completed_not_uploaded = current_user && !@drew_today && today_challenge &&
                              current_user.submissions.exists?(challenge: today_challenge)
  end
end
