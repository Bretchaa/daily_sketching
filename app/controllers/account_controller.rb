class AccountController < ApplicationController
  before_action :require_login

  def show
    @submissions = current_user.submissions
                               .joins(:image_attachment)
                               .includes(:image_attachment, :challenge)
                               .order(created_at: :desc)
    current_user.sync_shields!
    @streak = current_user.streak
    @shields_count = current_user.shields_count
    @shield_cap = User::MAX_SHIELDS
    @tab = params[:tab] == "settings" ? "settings" : "drawings"

    if @submissions.empty?
      today_challenge = Challenge.find_by(date: Date.current)
      today_submission = today_challenge && current_user.submissions.find_by(challenge: today_challenge)
      @started_today = today_submission.present?
      @uploaded_today = today_submission&.image&.attached? || false
    end
  end

  def destroy
    user = current_user
    session.delete(:user_id)
    user.submissions.each { |s| s.image.purge if s.image.attached? }
    user.destroy
    redirect_to root_path, notice: "Your account has been deleted."
  end

  private

  def require_login
    redirect_to sign_in_path unless current_user
  end
end
