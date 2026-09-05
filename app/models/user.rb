class User < ApplicationRecord
  has_many :submissions
  has_many :cheers
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

  def streak
    drawn_dates = submissions.joins(:challenge)
                             .pluck("challenges.date")
                             .map(&:to_date)
                             .to_set

    count = 0
    # Start from today; if not drawn today, start from yesterday
    start = drawn_dates.include?(Date.current) ? Date.current : Date.yesterday
    day = start
    while drawn_dates.include?(day)
      count += 1
      day -= 1
    end
    count
  end
end
