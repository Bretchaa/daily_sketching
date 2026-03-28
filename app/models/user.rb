class User < ApplicationRecord
  has_many :submissions
  has_many :cheers
  has_secure_password validations: false

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true, allow_nil: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.avatar_url = auth.info.image
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
end
