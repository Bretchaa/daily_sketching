class ApplicationController < ActionController::Base
  helper_method :current_user, :mobile?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def mobile?
    request.user_agent.to_s =~ /Mobile|Android|iPhone|iPad/i
  end
end


