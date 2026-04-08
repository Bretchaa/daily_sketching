class GalleryController < ApplicationController
  def show
    date = Date.parse(params[:date]) rescue Date.yesterday
    @challenge = Challenge.find_by!(date: date)
    all = @challenge.submissions.includes(:user, image_attachment: :blob)
                    .select { |s| s.image.attached? }
    my = current_user ? all.find { |s| s.user_id == current_user.id } : nil
    @submissions = ([ my ] + all.reject { |s| s == my }).compact
    @date = date
    @my_cheers = current_user ? current_user.cheers.where(submission: @submissions).index_by(&:submission_id) : {}
  end
end
