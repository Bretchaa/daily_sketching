class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.password_digest&.present?
      user.generate_password_reset_token!
      UserMailer.password_reset(user).deliver_now
    end
    # Always show the same message to prevent email enumeration
    redirect_to sign_in_path, notice: "If that email exists, you'll receive a reset link shortly."
  end

  def edit
    @user = User.find_by(reset_password_token: params[:token])
    redirect_to sign_in_path if @user.nil? || @user.password_reset_expired?
  end

  def update
    @user = User.find_by(reset_password_token: params[:token])
    if @user.nil? || @user.password_reset_expired?
      redirect_to sign_in_path
    elsif @user.update(password: params[:password], reset_password_token: nil, reset_password_sent_at: nil)
      session[:user_id] = @user.id
      redirect_to root_path
    else
      @error = @user.errors.full_messages.first
      render :edit, status: :unprocessable_entity
    end
  end
end
