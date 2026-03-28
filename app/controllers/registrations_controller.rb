class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(
      username: params[:username],
      email: params[:email],
      password: params[:password],
      name: params[:username]
    )

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path
    else
      @error = @user.errors.full_messages.first
      render :new, status: :unprocessable_entity
    end
  end

  def pick_username
    @user = current_user
  end

  def set_username
    if current_user.update(username: params[:username])
      redirect_to root_path
    else
      @error = current_user.errors.full_messages.first
      @user = current_user
      render :pick_username, status: :unprocessable_entity
    end
  end
end
