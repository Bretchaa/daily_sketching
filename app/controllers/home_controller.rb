class HomeController < ApplicationController
  def index
    yesterday = Challenge.find_by(date: Date.yesterday)
    if yesterday
      @yesterday_submissions = yesterday.submissions
                                        .joins(:image_attachment)
                                        .includes(:user, :cheers)
                                        .order(created_at: :desc)
      @yesterday_theme = yesterday.theme
      @yesterday_count = @yesterday_submissions.size
    else
      @yesterday_submissions = []
    end
  end
end
