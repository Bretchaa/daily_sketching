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

    # All users
    @all_users = User.order(created_at: :desc)

    # Today's participants
    today_challenge = Challenge.find_by(date: Date.current)
    @today_participants = today_challenge ? today_challenge.submissions.includes(:user, :image_attachment).order(:created_at) : []

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

  def daily_report
    AdminMailer.daily_report.deliver_now
    render plain: "Report sent."
  end

  def generate_challenges
    days = 30
    config = YAML.load_file(Rails.root.join("config", "challenge_themes.yml"))
    themes = config["challenges"]
    cooldowns = themes.each_with_object({}) { |t, h| h[t["theme"]] = t["cooldown_days"] || 1 }
    pool = themes.flat_map { |t| Array.new(t["weight"], t["theme"]) }

    generated = 0
    skipped = 0

    recent_history = Challenge.where(date: (Date.current - 14)...Date.current)
                              .order(:date).pluck(:date, :theme).to_h

    (0...days).each do |offset|
      date = Date.current + offset

      if Challenge.exists?(date: date)
        recent_history[date] = Challenge.find_by(date: date).theme
        skipped += 1
        next
      end

      on_cooldown = themes.filter_map { |t|
        cooldown = cooldowns[t["theme"]]
        t["theme"] if (1..cooldown).any? { |d| recent_history[date - d] == t["theme"] }
      }

      seed = Zlib.crc32("challenge-#{date.iso8601}")
      rng = Random.new(seed)
      available_pool = pool.reject { |t| on_cooldown.include?(t) }
      available_pool = pool if available_pool.empty?
      theme = available_pool.sample(random: rng)
      theme_config = themes.find { |t| t["theme"] == theme }

      Challenge.create!(
        date: date,
        theme: theme,
        focus: theme_config["focus"],
        tip: theme_config["tip"],
        example_image_url: theme_config["example_image_url"]
      )

      recent_history[date] = theme
      generated += 1
    end

    render plain: "Done. #{generated} challenges created, #{skipped} already existed."
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic("Daily Sketching Admin") do |_, password|
      password == ENV.fetch("ADMIN_PASSWORD", "admin")
    end
  end
end
