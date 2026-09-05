class UnsubscribesController < ApplicationController
  skip_before_action :require_login, raise: false

  def show
    @user = User.find_by(unsubscribe_token: params[:token])
    if @user
      @user.update!(email_notifications: false)
    else
      @invalid = true
    end
  end
end
