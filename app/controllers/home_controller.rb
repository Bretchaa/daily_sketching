class HomeController < ApplicationController
  def index
    recent_challenge = (1..7).each do |days_ago|
      challenge = Challenge.find_by(date: Date.current - days_ago)
      next unless challenge
      subs = challenge.submissions.joins(:image_attachment)
      break challenge if subs.exists?
    end

    if recent_challenge.is_a?(Challenge)
      subs = recent_challenge.submissions
                             .joins(:image_attachment)
                             .includes(:user, :cheers)
                             .order(created_at: :desc)
                             .to_a
      my_sub = current_user ? subs.find { |s| s.user_id == current_user.id } : nil
      @yesterday_submissions = ([ my_sub ] + subs.reject { |s| s == my_sub }).compact
      @my_yesterday_submission = my_sub
      @yesterday_theme = recent_challenge.theme
      @yesterday_count = @yesterday_submissions.size
      @gallery_date = recent_challenge.date
    else
      @yesterday_submissions = []
    end

    @streak = current_user ? current_user.streak : 0
    @drew_today = current_user && Challenge.find_by(date: Date.current)&.then { |c|
      current_user.submissions.joins(:image_attachment).exists?(challenge: c)
    }
  end
end
