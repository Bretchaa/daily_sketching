class User < ApplicationRecord
  has_many :submissions
  has_many :cheers
  has_many :shield_uses
  has_secure_password validations: false

  before_create :generate_unsubscribe_token

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true, allow_nil: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    user ||= find_by(email: auth.info.email)

    if user
      user.update_columns(provider: auth.provider, uid: auth.uid) if user.provider.nil?
      user
    else
      create!(
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        email: auth.info.email,
        avatar_url: auth.info.image
      )
    end
  end

  def upload_token
    super || generate_upload_token!
  end

  def generate_upload_token!
    update_column(:upload_token, SecureRandom.urlsafe_base64(24))
    self[:upload_token]
  end

  def google?
    provider == "google_oauth2"
  end

  def needs_username?
    username.blank?
  end

  def generate_password_reset_token!
    update!(
      reset_password_token: SecureRandom.urlsafe_base64(32),
      reset_password_sent_at: Time.current
    )
  end

  def password_reset_expired?
    reset_password_sent_at < 2.hours.ago
  end

  def generate_unsubscribe_token
    self.unsubscribe_token ||= SecureRandom.urlsafe_base64(32)
  end

  MAX_SHIELDS = 2
  SHIELD_MILESTONE_INTERVAL = 7

  # How many shields the last sync_shields! call spent bridging missed days.
  # Transient — not persisted, just a way for the caller to know what happened.
  attr_reader :shields_spent

  def streak
    run_length(drawn_dates | shield_uses.pluck(:date).to_set)
  end

  # Grants shields (streak restart, every 7-day milestone) and auto-spends a
  # shield to bridge a missed day so the streak keeps going.
  #
  # Call this before reading `streak` if you want it to reflect the latest
  # state (e.g. a day that was just missed and just got covered by a shield).
  # Returns how many shields were newly granted by this call (0 if none —
  # including when a milestone was hit but skipped because of the cap).
  def sync_shields!
    @shields_spent = 0
    drawn = drawn_dates
    return 0 if drawn.empty?

    covered = drawn | shield_uses.pluck(:date).to_set
    earliest_drawn = drawn.min

    # Walk backward from yesterday, spending a shield on every gap day we can
    # still afford. Today is never touched here, since it isn't over yet, and
    # we never walk earlier than the user's first-ever drawing.
    day = Date.yesterday
    until covered.include?(day)
      break if day < earliest_drawn
      break if shields_count <= 0
      shield_uses.create!(date: day)
      covered << day
      self.shields_count -= 1
      @shields_spent += 1
      day -= 1
    end

    streak_length = run_length(covered)
    newly_granted = grant_restart_shield(streak_length) + grant_milestone_shields(streak_length)

    save!
    newly_granted
  end

  private

  # Anyone starting a streak from zero (their very first-ever drawing, or a
  # comeback after breaking one) gets a shield. Only fires once per run: it
  # arms again as soon as the streak drops back to zero.
  def grant_restart_shield(streak_length)
    if streak_length.zero?
      self.restart_shield_granted = false
      0
    elsif !restart_shield_granted?
      self.restart_shield_granted = true
      grant_shield
    else
      0
    end
  end

  def drawn_dates
    submissions.joins(:challenge).pluck("challenges.date").map(&:to_date).to_set
  end

  def run_length(covered_dates)
    count = 0
    day = drawn_dates.include?(Date.current) ? Date.current : Date.yesterday
    while covered_dates.include?(day)
      count += 1
      day -= 1
    end
    count
  end

  def grant_milestone_shields(streak_length)
    target_milestone = (streak_length / SHIELD_MILESTONE_INTERVAL) * SHIELD_MILESTONE_INTERVAL
    granted = 0

    if target_milestone > shield_milestone_day
      new_milestones = (target_milestone - shield_milestone_day) / SHIELD_MILESTONE_INTERVAL
      new_milestones.times { granted += grant_shield }
    end

    # Keeps the counter in sync even when the streak shrinks (real break),
    # so a future run re-evaluates milestones instead of skipping them.
    self.shield_milestone_day = target_milestone
    granted
  end

  # Adds a shield unless already at the cap. Returns 1 if granted, 0 if skipped.
  def grant_shield
    return 0 unless shields_count < MAX_SHIELDS

    self.shields_count += 1
    1
  end
end
