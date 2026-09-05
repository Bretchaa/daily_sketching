class Admin::BaseController < ApplicationController
  before_action :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_basic("Daily Sketching Admin") do |_, password|
      password == ENV.fetch("ADMIN_PASSWORD", "admin")
    end
  end
end
