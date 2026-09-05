# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def password_reset
    UserMailer.password_reset(User.first)
  end

  # http://localhost:3000/rails/mailers/user_mailer/first_challenge_followup
  def first_challenge_followup
    UserMailer.first_challenge_followup(User.first)
  end

  # http://localhost:3000/rails/mailers/user_mailer/first_challenge_nudge
  def first_challenge_nudge
    UserMailer.first_challenge_nudge(User.first)
  end

  # http://localhost:3000/rails/mailers/user_mailer/reengagement
  def reengagement
    UserMailer.reengagement(User.first)
  end

  # http://localhost:3000/rails/mailers/user_mailer/streak_break
  def streak_break
    UserMailer.streak_break(User.first, 5)
  end
end
