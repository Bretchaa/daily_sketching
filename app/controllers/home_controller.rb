class HomeController < ApplicationController
  def index
    recent_challenge = (1..7).each do |days_ago|
      challenge = Challenge.find_by(date: Date.current - days_ago)
      next unless challenge
      subs = challenge.submissions.joins(:image_attachment)
      break challenge if subs.exists?
    end

    if recent_challenge.is_a?(Challenge)
      @yesterday_submissions = recent_challenge.submissions
                                               .joins(:image_attachment)
                                               .includes(:user, :cheers)
                                               .order(created_at: :desc)
      @yesterday_theme = recent_challenge.theme
      @yesterday_count = @yesterday_submissions.size
      @gallery_date = recent_challenge.date
    else
      @yesterday_submissions = []
    end
  end
end
