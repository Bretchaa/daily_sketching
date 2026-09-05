class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    @reset_url = edit_password_reset_url(token: user.reset_password_token)
    mail to: user.email, subject: "Reset your Daily Sketching password"
  end

  def first_challenge_followup(user)
    @user = user
    mail to: user.email, subject: "Draw again today" do |format|
      format.html
      format.text
    end
  end

  def first_challenge_nudge(user)
    @user = user
    mail to: user.email, subject: "Your first challenge is waiting" do |format|
      format.html
      format.text
    end
  end

  def reengagement(user)
    @user = user
    mail to: user.email, subject: "7 days without drawing. Let's fix that" do |format|
      format.html
      format.text
    end
  end

  def streak_break(user, streak_length)
    @user = user
    @streak_length = streak_length
    mail to: user.email, subject: "It's all good, come draw with us today" do |format|
      format.html
      format.text
    end
  end
end
