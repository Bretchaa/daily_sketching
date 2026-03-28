class SubmissionsController < ApplicationController
  def create
    challenge = Challenge.find_by!(date: Date.current)

    # Replace existing submission if user already uploaded today
    submission = current_user.submissions.find_or_initialize_by(challenge: challenge)
    submission.image = params[:image]

    if submission.save
      redirect_to done_path
    else
      redirect_to done_path, alert: "Upload failed, please try again."
    end
  end
end
