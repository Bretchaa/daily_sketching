class AccountController < ApplicationController
  before_action :require_login

  def show
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
