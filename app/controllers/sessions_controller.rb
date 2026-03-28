class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      @error = "Incorrect email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def google
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    if user.needs_username?
      redirect_to pick_username_path
    else
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
