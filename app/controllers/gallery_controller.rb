class GalleryController < ApplicationController
  def show
    date = Date.parse(params[:date]) rescue Date.yesterday
    @challenge = Challenge.find_by!(date: date)
    @submissions = @challenge.submissions.includes(:user, image_attachment: :blob)
                             .select { |s| s.image.attached? }
    @date = date
    @my_cheers = current_user ? current_user.cheers.where(submission: @submissions).index_by(&:submission_id) : {}
  end
end
