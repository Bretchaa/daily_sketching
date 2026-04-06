class AdminController < ApplicationController
  before_action :authenticate

  def dashboard
    # Acquisition
    @total_users        = User.count
    @new_users_today    = User.where(created_at: Date.current.all_day).count
    @new_users_week     = User.where(created_at: 7.days.ago..).count
    @new_users_month    = User.where(created_at: 30.days.ago..).count
    @google_signups     = User.where(provider: "google_oauth2").count
    @email_signups      = User.where(provider: [ nil, "" ]).count

    # Activation
    activated           = User.joins(:submissions).distinct.count
    @activation_rate    = @total_users > 0 ? (activated * 100.0 / @total_users).round : 0
    uploaded            = User.joins(:submissions).merge(Submission.joins(:image_attachment)).distinct.count
    @upload_rate        = @total_users > 0 ? (uploaded * 100.0 / @total_users).round : 0

    # Retention
    @active_7d          = User.joins(:submissions).where(submissions: { created_at: 7.days.ago.. }).distinct.count
    @active_30d         = User.joins(:submissions).where(submissions: { created_at: 30.days.ago.. }).distinct.count
    @avg_challenges     = @total_users > 0 ? (Submission.count.to_f / @total_users).round(1) : 0

    # Engagement
    @uploads_today      = Submission.joins(:image_attachment).where(created_at: Date.current.all_day).count
    @uploads_week       = Submission.joins(:image_attachment).where(created_at: 7.days.ago..).count
    @total_cheers       = Cheer.sum(:count)
    @top_submission     = Submission.joins(:cheers)
                                    .where(cheers: { created_at: 7.days.ago.. })
                                    .select("submissions.*, SUM(cheers.count) as cheer_total")
                                    .group("submissions.id")
                                    .order("cheer_total DESC")
                                    .includes(:user)
                                    .first

    # Daily pulse — last 14 days
    @daily_stats = (13.downto(0)).map do |i|
      date = Date.current - i.days
      {
        date: date,
        challenges: Submission.where(created_at: date.all_day).count,
        uploads: Submission.joins(:image_attachment).where(created_at: date.all_day).count,
        new_users: User.where(created_at: date.all_day).count
      }
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic("Daily Sketching Admin") do |_, password|
      password == ENV.fetch("ADMIN_PASSWORD", "admin")
    end
  end
end
