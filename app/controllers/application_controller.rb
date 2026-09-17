class ApplicationController < ActionController::Base
  CANONICAL_HOST = "dailysketching.app"

  before_action :redirect_to_canonical_host

  helper_method :current_user, :mobile?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def mobile?
    request.user_agent.to_s =~ /Mobile|Android|iPhone|iPad/i
  end

  private

  # Fly.io gives every app a free *.fly.dev address alongside our custom
  # domain. Redirect it so search engines only ever index one canonical URL.
  def redirect_to_canonical_host
    return unless Rails.env.production?
    return if request.host == CANONICAL_HOST
    return if request.path == "/up"

    redirect_to "https://#{CANONICAL_HOST}#{request.fullpath}", status: :moved_permanently, allow_other_host: true
  end
end